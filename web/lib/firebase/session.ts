import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import { getAdminAuth, getAdminDb } from "@/lib/firebase/firebaseAdmin";
import { toRole, type Role } from "@/lib/models";

export interface SessionUser {
  uid: string;
  role: Role;
  fullName: string;
  profileComplete: boolean;
  mustResetPassword: boolean;
}

/** Verifies the session cookie and reads the caller's role from users/{uid}. */
export async function getSessionUser(): Promise<SessionUser | null> {
  const cookie = (await cookies()).get("session")?.value;
  if (!cookie) return null;

  try {
    const decoded = await getAdminAuth().verifySessionCookie(cookie, true);
    const snap = await getAdminDb().collection("users").doc(decoded.uid).get();
    const data = snap.data() ?? {};
    return {
      uid: decoded.uid,
      role: toRole(data.role),
      fullName: typeof data.fullName === "string" ? data.fullName : "",
      profileComplete: data.profileComplete === true,
      mustResetPassword: data.mustResetPassword === true,
    };
  } catch {
    return null;
  }
}

/**
 * Server-side gate for app pages: signed in, password reset done, and (for
 * students) first-run setup done. Optionally restricts to [roles].
 */
export async function requireUser(roles?: Role[]): Promise<SessionUser> {
  const user = await getSessionUser();
  // An invalid/expired cookie would otherwise bounce between /login and /.
  if (!user) redirect("/api/logout");
  if (user.mustResetPassword) redirect("/reset-password");
  if (user.role === "student" && !user.profileComplete) redirect("/setup");
  if (roles && !roles.includes(user.role)) redirect("/");
  return user;
}
