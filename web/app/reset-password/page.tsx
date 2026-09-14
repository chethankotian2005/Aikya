import { redirect } from "next/navigation";
import ResetPasswordForm from "@/components/ResetPasswordForm";
import { AuthProvider } from "@/lib/auth-context";
import { getSessionUser } from "@/lib/firebase/session";

/** Forced first-login password change for faculty / coordinators / HOD (spec §5). */
export default async function ResetPasswordPage() {
  const user = await getSessionUser();
  if (!user) redirect("/api/logout");
  if (!user.mustResetPassword) redirect("/");

  return (
    <AuthProvider>
      <ResetPasswordForm />
    </AuthProvider>
  );
}
