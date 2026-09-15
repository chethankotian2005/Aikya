"use client";

import { useEffect, useRef, useState } from "react";
import { Html5Qrcode } from "html5-qrcode";
import { callBackend } from "@/lib/api";
import { friendlyError } from "@/lib/errors";

const SCANNER_ELEMENT_ID = "attendance-qr-reader";

/** Camera-based QR attendance scanner (coordinator/faculty/HOD). Scans a
 * student's personal QR (just their uid) and records it via
 * POST /api/attendance/scan — keeps scanning continuously so a whole
 * queue of students can check in one after another. */
export default function AttendanceScanner({
  eventId,
  sessions,
}: {
  eventId: string;
  sessions: string[];
}) {
  const [session, setSession] = useState(sessions[0] ?? "full");
  const [status, setStatus] = useState<{ message: string; tone: "idle" | "success" | "warning" | "error" }>({
    message: "Point the camera at a student’s QR code.",
    tone: "idle",
  });
  const scannerRef = useRef<Html5Qrcode | null>(null);
  const busyRef = useRef(false);
  const lastCodeRef = useRef<{ code: string; at: number } | null>(null);
  const sessionRef = useRef(session);

  useEffect(() => {
    sessionRef.current = session;
  }, [session]);

  useEffect(() => {
    const scanner = new Html5Qrcode(SCANNER_ELEMENT_ID);
    scannerRef.current = scanner;
    let cancelled = false;

    scanner
      .start(
        { facingMode: "environment" },
        { fps: 10, qrbox: { width: 250, height: 250 } },
        async (decodedText) => {
          if (cancelled || busyRef.current) return;
          const now = Date.now();
          if (lastCodeRef.current?.code === decodedText && now - lastCodeRef.current.at < 3000) return;
          lastCodeRef.current = { code: decodedText, at: now };

          busyRef.current = true;
          try {
            const result = await callBackend<{ alreadyMarked: boolean; studentName: string; usn: string | null }>(
              "attendance/scan",
              { eventId, studentUid: decodedText, session: sessionRef.current },
            );
            const who = `${result.studentName}${result.usn ? ` (${result.usn})` : ""}`;
            setStatus(
              result.alreadyMarked
                ? { message: `${who} was already marked present.`, tone: "warning" }
                : { message: `${who} marked present ✓`, tone: "success" },
            );
          } catch (err) {
            setStatus({ message: friendlyError(err), tone: "error" });
          } finally {
            busyRef.current = false;
          }
        },
        () => {}, // per-frame "no QR found" noise — ignore
      )
      .catch(() => setStatus({ message: "Could not start the camera. Check camera permissions.", tone: "error" }));

    return () => {
      cancelled = true;
      scanner.stop().then(() => scanner.clear()).catch(() => {});
    };
  }, [eventId]);

  const toneClass = {
    idle: "text-white/70",
    success: "text-success",
    warning: "text-warning",
    error: "text-error",
  }[status.tone];

  return (
    <div className="flex flex-col bg-black">
      {sessions.length > 1 && (
        <div className="flex gap-2 bg-primary p-3">
          {sessions.map((s) => (
            <button
              key={s}
              type="button"
              onClick={() => setSession(s)}
              className={`flex-1 rounded-full px-4 py-1.5 text-sm font-medium transition ${
                session === s ? "bg-accent text-white" : "bg-white/10 text-white/70"
              }`}
            >
              {s === "morning" ? "Morning" : "Afternoon"}
            </button>
          ))}
        </div>
      )}
      <div id={SCANNER_ELEMENT_ID} className="mx-auto w-full max-w-md" />
      <div className={`bg-primary p-5 text-center text-sm font-semibold ${toneClass}`}>{status.message}</div>
    </div>
  );
}
