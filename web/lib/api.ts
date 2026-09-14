"use client";

import { auth } from "@/lib/firebase/firebase";

export class ApiError extends Error {
  constructor(public status: number, message: string) {
    super(message);
  }
}

/**
 * Calls the shared Render backend (spec §7) through the same-origin
 * /api/backend proxy, carrying the caller's Firebase ID token.
 */
export async function callBackend<T = Record<string, unknown>>(
  path: string,
  body: unknown,
  method: "POST" | "PUT" = "POST",
): Promise<T> {
  const user = auth.currentUser;
  if (!user) throw new ApiError(401, "Please sign in again.");

  const token = await user.getIdToken();
  let res: Response;
  try {
    res = await fetch(`/api/backend/${path}`, {
      method,
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
      body: JSON.stringify(body),
    });
  } catch {
    throw new ApiError(0, "Could not reach the AIKYA server. Check your connection and try again.");
  }

  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw new ApiError(res.status, data.error || `Request failed (${res.status}).`);
  return data as T;
}
