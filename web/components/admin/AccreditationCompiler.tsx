"use client";

import { useState } from "react";
import { Timestamp, collection, limit, orderBy, query, where } from "firebase/firestore";
import { CalendarX, FileText, Sparkles } from "lucide-react";
import { db } from "@/lib/firebase/firebase";
import { callBackend } from "@/lib/api";
import { friendlyError } from "@/lib/errors";
import { useLiveQuery } from "@/lib/hooks";
import { formatDate, formatDateTime, toDate, toEvent } from "@/lib/models";
import { AiBadge, EmptyState, ErrorText, PageSpinner } from "@/components/ui";

const defaultSemester = () => {
  const now = new Date();
  return now.getMonth() >= 6 ? `${now.getFullYear()} Odd Semester` : `${now.getFullYear()} Even Semester`;
};

/** HOD-only Accreditation Compiler — POST /api/compile-accreditation. */
export default function AccreditationCompiler() {
  const events = useLiveQuery(
    () => query(collection(db, "events"), where("eventDate", "<", Timestamp.now()), orderBy("eventDate", "desc"), limit(100)),
    toEvent,
    [],
  );
  const reports = useLiveQuery(
    () => query(collection(db, "accreditationReports"), orderBy("generatedAt", "desc"), limit(20)),
    (id, d) => ({
      id,
      semesterLabel: String(d.semesterLabel ?? "Report"),
      pdfUrl: typeof d.pdfUrl === "string" ? d.pdfUrl : null,
      eventCount: Array.isArray(d.includedEventIds) ? d.includedEventIds.length : 0,
      generatedAt: toDate(d.generatedAt),
    }),
    [],
  );
  const [semester, setSemester] = useState(defaultSemester);
  const [selected, setSelected] = useState<Set<string>>(new Set());
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");
  const [result, setResult] = useState<{ pdfUrl: string; eventCount: number } | null>(null);

  const toggle = (id: string) =>
    setSelected((s) => {
      const next = new Set(s);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });

  const compile = async () => {
    setError("");
    setResult(null);
    setBusy(true);
    try {
      setResult(await callBackend("compile-accreditation", { semesterLabel: semester.trim(), eventIds: [...selected] }));
    } catch (err) {
      setError(friendlyError(err));
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="flex flex-col gap-5 p-5">
      <div>
        <h2 className="flex items-center gap-2 text-2xl font-extrabold text-text-primary">Accreditation Compiler <AiBadge /></h2>
        <p className="mt-1 text-[13px] text-text-secondary">
          Select past events to compile into one NAAC/NBA-ready PDF. Events with a generated report give Gemini more to work with.
        </p>
      </div>
      <div>
        <label htmlFor="acc-sem" className="label">Academic period</label>
        <input id="acc-sem" className="input" value={semester} onChange={(e) => setSemester(e.target.value)} />
      </div>

      {events.loading ? (
        <PageSpinner />
      ) : events.data.length === 0 ? (
        <EmptyState icon={CalendarX} message={events.error || "No past events to compile yet."} />
      ) : (
        <div className="card divide-y divide-border">
          <label className="flex items-center gap-3 p-4 font-semibold text-text-primary">
            <input
              type="checkbox"
              className="h-4 w-4 accent-secondary"
              checked={selected.size === events.data.length}
              onChange={(e) => setSelected(e.target.checked ? new Set(events.data.map((ev) => ev.id)) : new Set())}
            />
            Select all ({events.data.length})
          </label>
          {events.data.map((e) => (
            <label key={e.id} className="flex items-start gap-3 p-4">
              <input type="checkbox" className="mt-1 h-4 w-4 accent-secondary" checked={selected.has(e.id)} onChange={() => toggle(e.id)} />
              <span>
                <span className="block text-sm font-semibold text-text-primary">{e.title}</span>
                <span className="text-xs text-text-secondary">
                  {formatDateTime(e.eventDate)} · {e.currentRegistrations} registered{e.reportMarkdown ? " · report ready" : ""}
                </span>
              </span>
            </label>
          ))}
        </div>
      )}

      <ErrorText message={error} />
      {result && (
        <div role="status" className="flex flex-wrap items-center gap-3 rounded-lg bg-success/10 p-4 text-sm font-semibold text-success">
          Compiled {result.eventCount} events.
          <a href={result.pdfUrl} target="_blank" rel="noopener noreferrer" className="btn-primary px-4 py-2">Open PDF</a>
        </div>
      )}
      <button type="button" className="btn-primary w-full py-3" onClick={compile} disabled={busy || selected.size === 0 || !semester.trim()}>
        <Sparkles size={18} aria-hidden /> {busy ? "Compiling… (up to a minute)" : `Compile ${selected.size} events`}
      </button>

      {reports.data.length > 0 && (
        <section>
          <h3 className="mb-3 font-bold text-text-primary">Previous reports</h3>
          <ul className="flex flex-col gap-2">
            {reports.data.map((r) => (
              <li key={r.id} className="card flex items-center gap-3 p-4">
                <FileText size={20} className="text-error" aria-hidden />
                <div className="flex-1">
                  <p className="text-sm font-semibold text-text-primary">{r.semesterLabel}</p>
                  <p className="text-xs text-text-tertiary">
                    {r.eventCount} events{r.generatedAt ? ` · ${formatDate(r.generatedAt)}` : ""}
                  </p>
                </div>
                {r.pdfUrl && (
                  <a href={r.pdfUrl} target="_blank" rel="noopener noreferrer" className="btn-outline px-4 py-2">Open</a>
                )}
              </li>
            ))}
          </ul>
        </section>
      )}
    </div>
  );
}
