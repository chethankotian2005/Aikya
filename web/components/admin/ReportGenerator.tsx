"use client";

import { useState } from "react";
import { addDoc, collection, serverTimestamp } from "firebase/firestore";
import { ArrowLeft, Download, ImagePlus, Printer, Sparkles, Upload } from "lucide-react";
import { db } from "@/lib/firebase/firebase";
import { callBackend } from "@/lib/api";
import { useAuth } from "@/lib/auth-context";
import { friendlyError } from "@/lib/errors";
import { uploadImage } from "@/lib/upload";
import { AiBadge, ErrorText } from "@/components/ui";
import Markdown from "@/components/Markdown";
import { useManageableEvents } from "@/components/admin/useManageableEvents";

/** Post-event Report Generator — Gemini via POST /api/generate-report (saved onto the event). */
export default function ReportGenerator({ initialEventId }: { initialEventId: string }) {
  const { profile } = useAuth();
  const events = useManageableEvents(profile);
  const [eventId, setEventId] = useState(initialEventId);
  const [brief, setBrief] = useState("");
  const [photos, setPhotos] = useState<File[]>([]);
  const [markdown, setMarkdown] = useState<string | null>(null);
  const [error, setError] = useState("");
  const [notice, setNotice] = useState("");
  const [busy, setBusy] = useState(false);

  const event = events.data.find((e) => e.id === eventId);

  const generate = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    if (!eventId) return setError("Pick the event this report is for.");
    if (brief.trim().length < 10) return setError("Write a short summary of the event (at least 10 characters).");
    setBusy(true);
    try {
      const context = [
        `Event photos: ${photos.length}`,
        ...photos.map((p, i) => `Photo ${i + 1}: ${p.name}, last modified ${new Date(p.lastModified).toISOString()}`),
      ].join("\n");
      const res = await callBackend<{ markdown: string }>("generate-report", {
        brief: brief.trim(),
        eventId,
        includeAttendance: true,
        additionalContext: context,
      });
      setMarkdown(res.markdown);
    } catch (err) {
      setError(friendlyError(err));
    } finally {
      setBusy(false);
    }
  };

  const download = () => {
    const blob = new Blob([markdown ?? ""], { type: "text/markdown" });
    const url = URL.createObjectURL(blob);
    const a = Object.assign(document.createElement("a"), { href: url, download: `${event?.title ?? "event"}-report.md` });
    a.click();
    URL.revokeObjectURL(url);
  };

  const publish = async () => {
    if (!profile || !markdown) return;
    setBusy(true);
    setError("");
    try {
      for (const [i, photo] of photos.entries()) {
        const imageUrl = await uploadImage(photo, "memory_frame");
        await addDoc(collection(db, "memoryFrames"), {
          uploadedBy: profile.uid,
          uploaderName: profile.fullName,
          imageUrl,
          caption: event?.title ?? "Event memory",
          eventName: event?.title ?? "",
          eventId,
          status: "pending",
          likesCount: 0,
          reportMarkdown: i === 0 ? markdown : null,
          createdAt: serverTimestamp(),
        });
      }
      setNotice("Submitted to the moderation queue.");
    } catch (err) {
      setError(friendlyError(err));
    } finally {
      setBusy(false);
    }
  };

  if (markdown !== null) {
    return (
      <div className="flex flex-col gap-4 p-5">
        <div className="flex flex-wrap gap-2 print:hidden">
          <button type="button" className="btn-outline" onClick={() => setMarkdown(null)}><ArrowLeft size={16} aria-hidden /> Back to editor</button>
          <button type="button" className="btn-outline" onClick={() => window.print()}><Printer size={16} aria-hidden /> Print / PDF</button>
          <button type="button" className="btn-outline" onClick={download}><Download size={16} aria-hidden /> Download .md</button>
          {photos.length > 0 && (
            <button type="button" className="btn-primary" onClick={publish} disabled={busy}>
              <Upload size={16} aria-hidden /> {busy ? "Publishing…" : "Publish to Memory Wall"}
            </button>
          )}
        </div>
        {notice && <p role="status" className="text-sm font-semibold text-success">{notice}</p>}
        <ErrorText message={error} />
        <article className="card overflow-hidden">
          <div className="bg-ai-badge-gradient py-2.5 text-center text-xs font-bold tracking-wider text-white">
            AI GENERATED — REVIEW BEFORE SHARING
          </div>
          <div className="p-6">
            <p className="mb-4 text-xs text-text-tertiary">Saved to {event?.title ?? "the event"} for the accreditation compiler.</p>
            <Markdown>{markdown}</Markdown>
          </div>
        </article>
      </div>
    );
  }

  return (
    <form onSubmit={generate} className="flex flex-col gap-5 p-5">
      <div>
        <h2 className="flex items-center gap-2 text-2xl font-extrabold text-text-primary">Event report <AiBadge /></h2>
        <p className="mt-1 text-[13px] text-text-secondary">
          Summarise what happened and add photos. Gemini drafts a formatted report using the event&apos;s registration data.
        </p>
      </div>
      <div>
        <label htmlFor="r-event" className="label">Event</label>
        <select id="r-event" className="input" value={eventId} onChange={(e) => setEventId(e.target.value)}>
          <option value="">{events.data.length ? "Choose an event" : "No events you can report on yet"}</option>
          {events.data.map((e) => <option key={e.id} value={e.id}>{e.title}</option>)}
        </select>
      </div>
      <div>
        <label htmlFor="r-brief" className="label">Summary notes</label>
        <textarea id="r-brief" className="input" rows={6} value={brief} onChange={(e) => setBrief(e.target.value)} placeholder="e.g. 50 students attended the GenAI workshop. We covered RAG and embeddings..." />
      </div>
      <div>
        <label className="btn-outline cursor-pointer">
          <ImagePlus size={16} aria-hidden /> Add photos ({photos.length})
          <input type="file" accept="image/*" multiple className="sr-only" onChange={(e) => setPhotos([...photos, ...Array.from(e.target.files ?? [])])} />
        </label>
        {photos.length > 0 && (
          <div className="no-scrollbar mt-3 flex gap-2 overflow-x-auto">
            {photos.map((p, i) => (
              <button key={`${p.name}-${i}`} type="button" aria-label={`Remove ${p.name}`} onClick={() => setPhotos(photos.filter((_, idx) => idx !== i))}>
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img src={URL.createObjectURL(p)} alt={p.name} className="h-24 w-32 rounded-md object-cover" />
              </button>
            ))}
          </div>
        )}
      </div>
      <ErrorText message={error} />
      <button type="submit" className="btn-primary w-full py-3" disabled={busy}>
        <Sparkles size={18} aria-hidden /> {busy ? "Generating… (can take up to a minute)" : "Generate report"}
      </button>
    </form>
  );
}
