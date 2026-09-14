import { NextRequest, NextResponse } from "next/server";
import { cookies } from "next/headers";

async function clearSession() {
  const cookieStore = await cookies();
  cookieStore.delete("session");
}

export async function POST() {
  await clearSession();
  return NextResponse.json({ status: "success" });
}

/** Used by server redirects when the session cookie is invalid or expired. */
export async function GET(request: NextRequest) {
  await clearSession();
  return NextResponse.redirect(new URL("/login", request.url));
}
