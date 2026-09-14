"use client";

import { useState } from "react";
import { addDoc, collection, doc, increment, limit, orderBy, query, serverTimestamp, updateDoc, where } from "firebase/firestore";
import { Camera, FileText, Heart, ImageOff, X } from "lucide-react";
import { db } from "@/lib/firebase/firebase";
import { useAuth } from "@/lib/auth-context";
import { friendlyError } from "@/lib/errors";
import { useLiveQuery } from "@/lib/hooks";
import { toFrame, type MemoryFrame } from "@/lib/models";
import { uniqueFileName, uploadImage } from "@/lib/upload";
import { AiBadge, EmptyState, ErrorText, PageHeader, PageSpinner, TagChip } from "@/components/ui";
import Markdown from "@/components/Markdown";

function UploadDialog({ onClose }: { onClose: () => void }) {
  const { profile } = useAuth();
  const [file, setFile] = useState<File | null>(null);
  const [preview, setPreview] = useState<string | null>(null);
  const [caption, setCaption] = useState("");
  const [eventName, setEventName] = useState("");
  const [error, setError] = useState("");
  const [saving, setSaving] = useState(false);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!file || !profile) return;
    setSaving(true);
    setError("");
    try {
      const imageUrl = await uploadImage(file, `memoryFrames/${profile.uid}/${uniqueFileName(file)}`);
      await addDoc(collection(db, "memoryFrames"), {
        uploadedBy: profile.uid,
        uploaderName: profile.fullName,
        imageUrl,
        caption: caption.trim(),
        eventName: eventName.trim(),
        eventId: null,
        status: "pending",
        likesCount: 0,
        reportMarkdown: null,
        createdAt: serverTimestamp(),
      });
      onClose();
      alert("Submitted — it will appear once the HOD approves it.");
    } catch (err) {
      setError(friendlyError(err));
      setSaving(false);
    }
  };

  return (
    <div className="fixed inset-0 z-[60] flex items-end justify-center bg-black/50 sm:items-center" onClick={onClose}>
      <form
        role="dialog"
        aria-modal="true"
        aria-label="Share a memory"
        onSubmit={submit}
        onClick={(e) => e.stopPropagation()}
        className="flex w-full max-w-lg flex-col gap-4 rounded-t-2xl bg-surface-elevated p-6 sm:rounded-2xl"
      >
        <div className="flex items-center justify-between">
          <h2 className="text-lg font-bold text-text-primary">Share a memory</h2>
          <button type="button" aria-label="Close" onClick={onClose} className="text-text-tertiary hover:text-text-primary">
            <X size={20} />
          </button>
        </div>
        <label className="flex aspect-video cursor-pointer items-center justify-center overflow-hidden rounded-lg border border-border bg-primary-container text-sm text-text-secondary">
          {preview ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img src={preview} alt="Preview" className="h-full w-full object-cover" />
          ) : (
            "Tap to choose a photo"
          )}
          <input
            type="file"
            accept="image/*"
            className="sr-only"
            onChange={(e) => {
              const f = e.target.files?.[0] ?? null;
              setFile(f);
              setPreview(f ? URL.createObjectURL(f) : null);
            }}
          />
        </label>
        <input aria-label="Caption" className="input" maxLength={200} placeholder="Caption" value={caption} onChange={(e) => setCaption(e.target.value)} />
        <input aria-label="Event" className="input" placeholder="Event (optional)" value={eventName} onChange={(e) => setEventName(e.target.value)} />
        <ErrorText message={error} />
        <button type="submit" className="btn-primary w-full" disabled={!file || saving}>
          {saving ? "Uploading…" : "Submit for approval"}
        </button>
      </form>
    </div>
  );
}

function FrameViewer({ frame, onClose }: { frame: MemoryFrame; onClose: () => void }) {
  const [liked, setLiked] = useState(false);

  const like = async () => {
    if (liked) return;
    setLiked(true);
    await updateDoc(doc(db, "memoryFrames", frame.id), { likesCount: increment(1) }).catch(() => setLiked(false));
  };

  return (
    <div className="fixed inset-0 z-[60] flex flex-col bg-black/95 text-white" role="dialog" aria-modal="true" aria-label="Photo">
      <div className="flex justify-end p-4">
        <button type="button" aria-label="Close" onClick={onClose} className="rounded-full bg-white/10 p-2 hover:bg-white/20">
          <X size={22} />
        </button>
      </div>
      <div className="flex-1 overflow-y-auto px-4 pb-8">
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img src={frame.imageUrl} alt={frame.caption || "Memory"} className="mx-auto max-h-[60vh] rounded-lg object-contain" />
        <div className="mx-auto mt-4 max-w-2xl">
          <p className="font-semibold">{frame.uploaderName}</p>
          {frame.caption && <p className="mt-1 text-white/80">{frame.caption}</p>}
          {frame.eventName && <p className="text-sm text-accent">{frame.eventName}</p>}
          <button type="button" onClick={like} className="mt-4 flex items-center gap-2 text-accent" aria-pressed={liked}>
            <Heart size={20} fill={liked ? "currentColor" : "none"} aria-hidden /> {frame.likesCount + (liked ? 1 : 0)}
          </button>
          {frame.reportMarkdown && (
            <div className="mt-6 rounded-lg bg-surface-elevated p-5 text-left">
              <div className="mb-3"><AiBadge label="AI Report" /></div>
              <Markdown>{frame.reportMarkdown}</Markdown>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default function MemoryWallPage() {
  const { profile } = useAuth();
  const [uploading, setUploading] = useState(false);
  const [viewing, setViewing] = useState<MemoryFrame | null>(null);

  const approved = useLiveQuery(
    () => query(collection(db, "memoryFrames"), where("status", "==", "approved"), orderBy("createdAt", "desc"), limit(60)),
    toFrame,
    [],
  );
  const mine = useLiveQuery(
    () =>
      profile
        ? query(collection(db, "memoryFrames"), where("uploadedBy", "==", profile.uid), orderBy("createdAt", "desc"), limit(30))
        : null,
    toFrame,
    [profile?.uid],
  );
  const awaiting = mine.data.filter((f) => f.status !== "approved");

  return (
    <div className="flex flex-col">
      <PageHeader title="Memory Wall" />
      <p className="px-5 text-[13px] text-text-secondary">Snapshots of our journey. Uploads appear after HOD approval.</p>

      {awaiting.length > 0 && (
        <section className="pt-4">
          <h2 className="px-5 pb-2 text-sm font-bold text-text-primary">Your uploads awaiting review</h2>
          <div className="no-scrollbar flex gap-2 overflow-x-auto px-5">
            {awaiting.map((f) => (
              <div key={f.id} className="relative h-24 w-24 shrink-0 overflow-hidden rounded-md">
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img src={f.imageUrl} alt="" className="h-full w-full object-cover" />
                <span className="absolute bottom-1 left-1">
                  <TagChip label={f.status} tone={f.status === "rejected" ? "error" : "warning"} />
                </span>
              </div>
            ))}
          </div>
        </section>
      )}

      <div className="px-5 pt-4 pb-10">
        {approved.loading ? (
          <PageSpinner />
        ) : approved.data.length === 0 ? (
          <EmptyState icon={ImageOff} message={approved.error || "No memories yet — tap Contribute to share the first photo."} />
        ) : (
          <div className="columns-2 gap-3">
            {approved.data.map((f, i) => (
              <button
                key={f.id}
                type="button"
                onClick={() => setViewing(f)}
                className={`relative mb-3 block w-full break-inside-avoid overflow-hidden rounded-lg border border-border ${i % 3 === 0 ? "aspect-[3/4]" : "aspect-square"}`}
              >
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img src={f.imageUrl} alt={f.caption || "Memory"} className="h-full w-full object-cover transition duration-500 hover:scale-105" />
                {f.reportMarkdown && (
                  <span className="absolute top-2 right-2 rounded-full bg-accent p-1.5 text-white">
                    <FileText size={14} aria-label="Has event report" />
                  </span>
                )}
                <span className="absolute inset-x-0 bottom-0 truncate bg-gradient-to-t from-black/80 to-transparent px-3 pt-10 pb-2.5 text-left text-[11px] font-semibold text-white">
                  {f.uploaderName}
                </span>
              </button>
            ))}
          </div>
        )}
      </div>

      <button
        type="button"
        onClick={() => setUploading(true)}
        className="fixed right-5 bottom-24 z-40 flex items-center gap-2 rounded-full bg-secondary px-5 py-3.5 text-sm font-semibold text-white shadow-lg transition hover:bg-accent-hover"
      >
        <Camera size={20} aria-hidden /> Contribute
      </button>

      {uploading && <UploadDialog onClose={() => setUploading(false)} />}
      {viewing && <FrameViewer frame={viewing} onClose={() => setViewing(null)} />}
    </div>
  );
}
