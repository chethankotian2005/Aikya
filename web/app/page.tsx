import { cookies } from "next/headers";
import { adminAuth } from "@/lib/firebase/firebaseAdmin";
import { redirect } from "next/navigation";

export default async function HomePage() {
  const cookieStore = await cookies();
  const session = cookieStore.get("session")?.value;

  if (!session) {
    redirect("/login");
  }

  try {
    const decodedClaims = await adminAuth.verifySessionCookie(session, true);
    // User is verified, we can fetch their profile
  } catch (error) {
    redirect("/login");
  }

  return (
    <div className="flex-1 p-6">
      <h1 className="text-3xl font-bold mb-4">Aikya Home</h1>
      <p className="text-text-secondary">Welcome to the Aikya platform. (Home Feed UI goes here)</p>
    </div>
  );
}
