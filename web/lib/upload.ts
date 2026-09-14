"use client";

import { getDownloadURL, ref, uploadBytes } from "firebase/storage";
import { storage } from "@/lib/firebase/firebase";

/** Uploads an image with its content type (storage.rules require image/*) and returns its URL. */
export async function uploadImage(file: File, path: string, maxMb = 10): Promise<string> {
  if (!file.type.startsWith("image/")) throw new Error("Please choose an image file.");
  if (file.size > maxMb * 1024 * 1024) throw new Error(`Images must be under ${maxMb} MB.`);

  const fileRef = ref(storage, path);
  await uploadBytes(fileRef, file, { contentType: file.type });
  return getDownloadURL(fileRef);
}

export function uniqueFileName(file: File): string {
  return `${Date.now()}_${file.name.replace(/[^A-Za-z0-9._-]/g, "_")}`;
}
