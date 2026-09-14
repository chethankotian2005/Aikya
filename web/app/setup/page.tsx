import { redirect } from "next/navigation";
import SetupForm from "@/components/SetupForm";
import { AuthProvider } from "@/lib/auth-context";
import { getSessionUser } from "@/lib/firebase/session";

/** First-run Profile Setup Wizard (students only, spec §6). */
export default async function SetupPage() {
  const user = await getSessionUser();
  if (!user) redirect("/api/logout");
  if (user.mustResetPassword) redirect("/reset-password");
  if (user.role !== "student" || user.profileComplete) redirect("/");

  return (
    <AuthProvider>
      <SetupForm />
    </AuthProvider>
  );
}
