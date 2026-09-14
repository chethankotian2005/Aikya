"use client";

import { useState } from "react";
import { collection, orderBy, query, where } from "firebase/firestore";
import { CheckCircle } from "lucide-react";
import { db } from "@/lib/firebase/firebase";
import { callBackend } from "@/lib/api";
import { friendlyError } from "@/lib/errors";
import { useLiveQuery } from "@/lib/hooks";
import { timeAgo, toFrame } from "@/lib/models";
import { AiBadge, EmptyState, ErrorText, PageSpinner } from "@/components/ui";

/** HOD photo moderation — decisions go through the backend so the uploader is notified. */
export default function ModerationQueue() {
  const frames = useLiveQuery(
    () => query(collection(db, "memoryFrames"), where("status", "==", "pending"), orderBy("createdAt", "desc")),
    toFrame,
    [],
  );
  const [busy, setBusy] = useState<string | null>(null);
  const [error, setError] = useState("");

  const review = async (id: string, approve: boolean) => {
    let note = "";
    if (!approve) {
      const input = prompt("Reason for rejecting (optional, sent to the uploader):");
      if (input === null) return;
      note = input.trim();
    }
    setBusy(id);
    setError("");
    try {
      await callBackend(`messaging/memory-frame/${approve ? "approve" : "reject"}`, { memoryId: id, note });
    } catch (err) {
      setError(friendlyError(err));
    } finally {
      setBusy(null);
    }
  };

  if (frames.loading) return <PageSpinner />;

  return (
    <div className="p-5">
      <ErrorText message={error || frames.error} />
      {frames.data.length === 0 ? (
        <EmptyState icon={CheckCircle} message="Queue is clear — nothing to review." />
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {frames.data.map((f) => (
            <div key={f.id} className="card flex flex-col overflow-hidden">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src={f.imageUrl} alt={f.caption || "Pending memory"} className="aspect-[4/3] w-full object-cover" />
              <div className="flex-1 p-4">
                <p className="font-bold text-text-primary">{f.uploaderName}</p>
                {f.caption && <p className="text-sm text-text-secondary">{f.caption}</p>}
                <p className="text-xs text-text-tertiary">{[f.eventName, timeAgo(f.createdAt)].filter(Boolean).join(" · ")}</p>
                {f.reportMarkdown && <div className="mt-2"><AiBadge label="Includes report" /></div>}
              </div>
              <div className="flex gap-2 border-t border-border p-3">
                <button type="button" className="btn-outline flex-1 text-error" disabled={busy === f.id} onClick={() => review(f.id, false)}>
                  Reject
                </button>
                <button type="button" className="btn-primary flex-1 bg-success" disabled={busy === f.id} onClick={() => review(f.id, true)}>
                  Approve
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
