"use client";

import { use, useEffect, useState } from "react";
import { doc, getDoc } from "firebase/firestore";
import { db } from "@/lib/firebase/firebase";
import { friendlyError } from "@/lib/errors";
import { toEvent } from "@/lib/models";
import { ErrorText, PageHeader, PageSpinner } from "@/components/ui";
import AttendanceScanner from "@/components/AttendanceScanner";

export default function ScanAttendancePage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const [title, setTitle] = useState("");
  const [sessions, setSessions] = useState<string[] | null>(null);
  const [error, setError] = useState("");

  useEffect(() => {
    getDoc(doc(db, "events", id))
      .then((snap) => {
        if (!snap.exists()) throw new Error("Event not found.");
        const e = toEvent(snap.id, snap.data());
        setTitle(e.title);
        setSessions(e.sessions);
      })
      .catch((err) => setError(friendlyError(err)));
  }, [id]);

  return (
    <div className="flex flex-col">
      <PageHeader title={title || "Scan attendance"} back />
      {error ? (
        <div className="p-5"><ErrorText message={error} /></div>
      ) : !sessions ? (
        <PageSpinner />
      ) : (
        <AttendanceScanner eventId={id} sessions={sessions} />
      )}
    </div>
  );
}
