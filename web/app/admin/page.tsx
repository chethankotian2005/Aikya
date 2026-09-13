import { cookies } from "next/headers";
import { adminAuth } from "@/lib/firebase/firebaseAdmin";
import { redirect } from "next/navigation";

export default async function AdminPage() {
  const cookieStore = await cookies();
  const session = cookieStore.get("session")?.value;

  if (!session) {
    redirect("/login");
  }

  try {
    const decodedClaims = await adminAuth.verifySessionCookie(session, true);
    
    // Example role guard
    if (decodedClaims.role !== "admin" && decodedClaims.role !== "coordinator" && decodedClaims.role !== "faculty") {
      return (
        <div className="flex-1 p-6">
          <h1 className="text-3xl font-bold mb-4 text-error">Access Denied</h1>
          <p className="text-text-secondary">You do not have permission to view this page.</p>
        </div>
      );
    }

    return (
      <div className="flex-1 p-6">
        <h1 className="text-3xl font-bold mb-4">Admin Dashboard</h1>
        <p className="text-text-secondary">Role-gated views go here (Role: {decodedClaims.role})</p>
      </div>
    );
  } catch (error) {
    redirect("/login");
  }
}
