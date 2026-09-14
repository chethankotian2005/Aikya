"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { callBackend } from "@/lib/api";
import { friendlyError } from "@/lib/errors";
import { ErrorText, PageHeader } from "@/components/ui";

export default function UpdateComposer() {
  const router = useRouter();
  const [content, setContent] = useState("");
  const [deadline, setDeadline] = useState("");
  const [error, setError] = useState("");
  const [posting, setPosting] = useState(false);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!content.trim()) return setError("Write something to share with the students.");
    setError("");
    setPosting(true);
    try {
      // Author, designation and club are filled in server-side from the verified caller.
      await callBackend("messaging/updates", {
        content: content.trim(),
        ...(deadline ? { deadlineDate: new Date(`${deadline}T23:59:00`).toISOString() } : {}),
      });
      router.push("/");
    } catch (err) {
      setError(friendlyError(err));
      setPosting(false);
    }
  };

  return (
    <div className="flex flex-col">
      <PageHeader title="Post Update" back />
      <form onSubmit={submit} className="flex flex-col gap-5 px-5 pt-4 pb-8">
        <div>
          <label htmlFor="u-content" className="label">Announcement</label>
          <textarea
            id="u-content"
            className="input"
            rows={8}
            maxLength={2000}
            value={content}
            onChange={(e) => setContent(e.target.value)}
            placeholder="What do you want to share with the students?"
          />
          <p className="mt-1 text-right text-xs text-text-tertiary">{content.length}/2000</p>
        </div>
        <div>
          <label htmlFor="u-deadline" className="label">Deadline (optional)</label>
          <input id="u-deadline" type="date" className="input" value={deadline} min={new Date().toISOString().slice(0, 10)} onChange={(e) => setDeadline(e.target.value)} />
        </div>
        <p className="text-xs text-text-tertiary">Students get a push notification when you post.</p>
        <ErrorText message={error} />
        <button type="submit" className="btn-primary w-full py-3" disabled={posting}>
          {posting ? "Posting…" : "Post update"}
        </button>
      </form>
    </div>
  );
}
