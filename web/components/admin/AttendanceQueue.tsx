"use client";

import { useEffect, useState } from "react";
import { collection, doc, getDoc, orderBy, query, where } from "firebase/firestore";
import { CheckCheck } from "lucide-react";
import { db } from "@/lib/firebase/firebase";
import { callBackend } from "@/lib/api";
import { friendlyError } from "@/lib/errors";
import { useLiveQuery } from "@/lib/hooks";
import { timeAgo, toAttendance } from "@/lib/models";
import { EmptyState, ErrorText, PageSpinner } from "@/components/ui";

/** HOD attendance / OD workspace — decisions go through the backend so the student is notified. */
export default function AttendanceQueue() {
  const requests = useLiveQuery(
    () => query(collection(db, "attendanceRequests"), where("status", "==", "pending"), orderBy("createdAt", "desc")),
    toAttendance,
    [],
  );
  const [names, setNames] = useState<Record<string, string>>({});
  const [busy, setBusy] = useState<string | null>(null);
  const [error, setError] = useState("");

  const ids = requests.data.flatMap((r) => [`users/${r.studentId}`, `events/${r.eventId}`]).join("|");

  useEffect(() => {
    const paths = [...new Set(ids.split("|").filter(Boolean))].filter((p) => !(p in names));
    if (paths.length === 0) return;
    Promise.all(paths.map((p) => getDoc(doc(db, p)))).then((snaps) => {
      setNames((current) => ({
        ...current,
        ...Object.fromEntries(
          snaps.map((s, i) => {
            const d = s.data() ?? {};
            return [paths[i], String(d.fullName ?? d.title ?? "Unknown") + (d.usn ? ` · ${d.usn}` : "")];
          }),
        ),
      }));
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [ids]);

  const review = async (id: string, approve: boolean) => {
    let note = "";
    if (!approve) {
      const input = prompt("Reason for rejecting (sent to the student):");
      if (input === null) return;
      note = input.trim();
    }
    setBusy(id);
    setError("");
    try {
      await callBackend(`messaging/attendance/${approve ? "approve" : "reject"}`, { requestId: id, note });
    } catch (err) {
      setError(friendlyError(err));
    } finally {
      setBusy(null);
    }
  };

  if (requests.loading) return <PageSpinner />;

  return (
    <div className="flex flex-col gap-4 p-5">
      <ErrorText message={error || requests.error} />
      {requests.data.length === 0 ? (
        <EmptyState icon={CheckCheck} message="All caught up — no pending requests." />
      ) : (
        requests.data.map((r) => (
          <div key={r.id} className="card p-5">
            <p className="font-bold text-text-primary">{names[`users/${r.studentId}`] ?? "Loading…"}</p>
            <p className="text-xs text-accent">{names[`events/${r.eventId}`] ?? ""}</p>
            <p className="mt-3 text-[13px] leading-relaxed text-text-secondary">{r.requestDetails}</p>
            <p className="mt-1 text-xs text-text-tertiary">Submitted {timeAgo(r.createdAt)}</p>
            <div className="mt-4 flex gap-3">
              <button type="button" className="btn-outline flex-1 text-error" disabled={busy === r.id} onClick={() => review(r.id, false)}>
                Reject
              </button>
              <button type="button" className="btn-primary flex-1 bg-success" disabled={busy === r.id} onClick={() => review(r.id, true)}>
                Approve
              </button>
            </div>
          </div>
        ))
      )}
    </div>
  );
}
