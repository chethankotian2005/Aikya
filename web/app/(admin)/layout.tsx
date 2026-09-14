import AdminShell from "@/components/AdminShell";
import { AuthProvider } from "@/lib/auth-context";
import { requireUser } from "@/lib/firebase/session";

/** Admin portal: coordinators (own events) and the HOD only — checked server-side. */
export default async function AdminLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const user = await requireUser(["coordinator", "hod"]);

  return (
    <AuthProvider>
      <AdminShell role={user.role} name={user.fullName}>
        {children}
      </AdminShell>
    </AuthProvider>
  );
}
