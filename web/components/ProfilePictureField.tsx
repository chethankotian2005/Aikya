"use client";

import { useEffect, useState } from "react";
import { ImagePlus } from "lucide-react";
import AvatarPicker from "@/components/AvatarPicker";

export type PictureMode = "avatar" | "photo";

/**
 * Lets a user pick a preset avatar (no upload, no storage cost) or upload
 * their own photo through Cloudinary (POST /api/upload-image). The two are
 * mutually exclusive — the caller sends `avatarId: null` when mode is
 * "photo" and `profilePictureUrl: null` when mode is "avatar" so the stored
 * profile never has both set at once.
 */
export default function ProfilePictureField({
  mode,
  onModeChange,
  avatarId,
  onAvatarChange,
  photoFile,
  onPhotoFileChange,
  existingPhotoUrl,
}: {
  mode: PictureMode;
  onModeChange: (m: PictureMode) => void;
  avatarId: number | null;
  onAvatarChange: (id: number) => void;
  photoFile: File | null;
  onPhotoFileChange: (f: File | null) => void;
  existingPhotoUrl: string | null;
}) {
  const [preview, setPreview] = useState<string | null>(existingPhotoUrl);

  useEffect(() => {
    if (!photoFile) {
      setPreview(existingPhotoUrl);
      return;
    }
    const url = URL.createObjectURL(photoFile);
    setPreview(url);
    return () => URL.revokeObjectURL(url);
  }, [photoFile, existingPhotoUrl]);

  return (
    <div className="flex flex-col items-center gap-4">
      <div className="flex gap-1 rounded-full bg-primary-container p-1 text-sm font-medium">
        {(["avatar", "photo"] as const).map((m) => (
          <button
            key={m}
            type="button"
            onClick={() => onModeChange(m)}
            className={`rounded-full px-4 py-1.5 transition ${
              mode === m ? "bg-secondary text-white" : "text-text-secondary"
            }`}
          >
            {m === "avatar" ? "Avatar" : "Upload photo"}
          </button>
        ))}
      </div>

      {mode === "avatar" ? (
        <AvatarPicker value={avatarId} onChange={onAvatarChange} />
      ) : (
        <label className="card flex h-32 w-32 cursor-pointer flex-col items-center justify-center gap-2 overflow-hidden rounded-full text-text-secondary">
          {preview ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img src={preview} alt="Profile preview" className="h-full w-full object-cover" />
          ) : (
            <>
              <ImagePlus size={24} />
              <span className="text-xs">Choose a photo</span>
            </>
          )}
          <input
            type="file"
            accept="image/*"
            className="hidden"
            onChange={(e) => onPhotoFileChange(e.target.files?.[0] ?? null)}
          />
        </label>
      )}
    </div>
  );
}
