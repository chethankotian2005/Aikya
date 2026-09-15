import { NextRequest, NextResponse } from "next/server";

/**
 * Same-origin proxy to the shared Render backend (spec §2/§7). Keeps the web
 * app off Render's CORS allowlist and hides the backend URL. The backend
 * verifies the forwarded Firebase ID token and role itself.
 */
const BACKEND_URL = process.env.BACKEND_URL ?? "https://aikya-backend-2t80.onrender.com/api";

const ALLOWED_PATHS = new Set([
  "profile",
  "generate-report",
  "compile-accreditation",
  "sentiment-rollup",
  "upload-image",
  "messaging/updates",
  "messaging/attendance/approve",
  "messaging/attendance/reject",
  "messaging/memory-frame/approve",
  "messaging/memory-frame/reject",
  "admin/provision-staff",
]);

// Render's free tier can take ~30s to wake up, plus Gemini generation time.
export const maxDuration = 60;

type Context = { params: Promise<{ path: string[] }> };

async function forward(request: NextRequest, { params }: Context) {
  const path = (await params).path.join("/");
  if (!ALLOWED_PATHS.has(path)) {
    return NextResponse.json({ error: "Not found" }, { status: 404 });
  }

  try {
    const response = await fetch(`${BACKEND_URL}/${path}`, {
      method: request.method,
      headers: {
        "Content-Type": request.headers.get("content-type") ?? "application/json",
        Authorization: request.headers.get("authorization") ?? "",
      },
      // Binary-safe for multipart uploads; request.text() would corrupt them.
      body: await request.arrayBuffer(),
      signal: AbortSignal.timeout(55_000),
    });

    return new NextResponse(await response.text(), {
      status: response.status,
      headers: { "Content-Type": response.headers.get("content-type") ?? "application/json" },
    });
  } catch {
    return NextResponse.json(
      { error: "The AIKYA server is waking up or unreachable. Please try again in a moment." },
      { status: 504 },
    );
  }
}

export const POST = forward;
export const PUT = forward;
