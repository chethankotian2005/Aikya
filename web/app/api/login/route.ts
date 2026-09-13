import { NextRequest, NextResponse } from "next/server";
import { adminAuth } from "@/lib/firebase/firebaseAdmin";
import { cookies } from "next/headers";

export async function POST(request: NextRequest) {
  try {
    const { idToken } = await request.json();

    if (!idToken) {
      return NextResponse.json({ error: "No ID token provided" }, { status: 401 });
    }

    // Set session expiration to 5 days
    const expiresIn = 60 * 60 * 24 * 5 * 1000;

    // Create the session cookie
    const sessionCookie = await adminAuth.createSessionCookie(idToken, { expiresIn });

    const options = {
      name: "session",
      value: sessionCookie,
      maxAge: expiresIn,
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      path: "/",
    };

    // Set cookie
    const cookieStore = await cookies();
    cookieStore.set(options);

    return NextResponse.json({ status: "success" }, { status: 200 });
  } catch (error: any) {
    console.error("Error creating session cookie:", error);
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}
