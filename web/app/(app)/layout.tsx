import BottomNav from "@/components/BottomNav";
import { AuthProvider } from "@/lib/auth-context";
import { requireUser } from "@/lib/firebase/session";

export default async function AppLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  await requireUser();

  return (
    <AuthProvider>
      <div className="flex min-h-screen flex-col bg-primary-surface">
        <div className="mx-auto w-full max-w-3xl flex-1 pb-24">{children}</div>
        <BottomNav />
      </div>
    </AuthProvider>
  );
}
