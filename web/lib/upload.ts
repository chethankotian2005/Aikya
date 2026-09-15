"use client";

import { auth } from "@/lib/firebase/firebase";
import { ApiError } from "@/lib/api";

export type UploadFolder = "profile_pictures" | "event_banners" | "memory_frame" | "project_images";

/**
 * Uploads an image through the authenticated backend (which forwards it to
 * Cloudinary — Firebase Storage now requires the Blaze plan) and returns its
 * secure URL.
 */
export async function uploadImage(file: File, folder: UploadFolder, maxMb = 10): Promise<string> {
  if (!file.type.startsWith("image/")) throw new Error("Please choose an image file.");
  if (file.size > maxMb * 1024 * 1024) throw new Error(`Images must be under ${maxMb} MB.`);

  const user = auth.currentUser;
  if (!user) throw new ApiError(401, "Please sign in again.");
  const token = await user.getIdToken();

  const form = new FormData();
  form.append("folder", folder);
  form.append("file", file);

  let res: Response;
  try {
    res = await fetch("/api/backend/upload-image", {
      method: "POST",
      headers: { Authorization: `Bearer ${token}` },
      body: form,
    });
  } catch {
    throw new ApiError(0, "Could not reach the AIKYA server. Check your connection and try again.");
  }

  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw new ApiError(res.status, data.error || `Upload failed (${res.status}).`);
  return data.secure_url as string;
}
