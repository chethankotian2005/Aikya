import { NextResponse } from "next/server";
import { cookies } from "next/headers";

export async function POST() {
  try {
    const cookieStore = await cookies();
    cookieStore.delete("session");

    return NextResponse.json({ status: "success" }, { status: 200 });
  } catch (error) {
    console.error("Error clearing session cookie:", error);
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}
