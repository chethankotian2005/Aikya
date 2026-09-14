"use client";

import { useState } from "react";
import Link from "next/link";
import { BarChart3, Sparkles } from "lucide-react";
import { callBackend } from "@/lib/api";
import { useAuth } from "@/lib/auth-context";
import { friendlyError } from "@/lib/errors";
import { formatDateTime } from "@/lib/models";
import { AiBadge, EmptyState, PageSpinner } from "@/components/ui";
import { useManageableEvents } from "@/components/admin/useManageableEvents";

/** Analytics + Feedback Sentiment Rollup (HOD: all events, coordinators: own). */
export default function AnalyticsPage() {
  const { profile } = useAuth();
  const events = useManageableEvents(profile);
  const [running, setRunning] = useState<string | null>(null);
  const [message, setMessage] = useState("");

  const runRollup = async (id: string, title: string) => {
    setRunning(id);
    setMessage("");
    try {
      const res = await callBackend<{ totalComments: number }>("sentiment-rollup", { eventId: id });
      setMessage(`Analysed ${res.totalComments} comments for "${title}".`);
    } catch (err) {
      setMessage(friendlyError(err));
    } finally {
      setRunning(null);
    }
  };

  if (events.loading) return <PageSpinner />;
  if (events.data.length === 0) return <EmptyState icon={BarChart3} message={events.error || "No events to analyse yet."} />;

  const registrations = events.data.reduce((s, e) => s + e.currentRegistrations, 0);
  const capacity = events.data.reduce((s, e) => s + e.maxCapacity, 0);
  const analysed = events.data.filter((e) => e.sentiment);
  const avgPositive = analysed.length
    ? Math.round(analysed.reduce((s, e) => s + (e.sentiment?.positive ?? 0), 0) / analysed.length)
    : null;

  return (
    <div className="flex flex-col gap-5 p-5">
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
        {[
          ["Events", String(events.data.length), false],
          ["Registrations", String(registrations), false],
          ["Fill rate", capacity ? `${Math.round((registrations * 100) / capacity)}%` : "–", false],
          ["Avg. positive", avgPositive === null ? "–" : `${avgPositive}%`, true],
        ].map(([label, value, ai]) => (
          <div key={label as string} className="card p-4">
            <p className="flex items-center gap-1.5 text-xs text-text-secondary">{label as string} {ai && <AiBadge />}</p>
            <p className="text-2xl font-extrabold text-text-primary">{value as string}</p>
          </div>
        ))}
      </div>

      {message && <p role="status" className="text-sm font-semibold text-text-secondary">{message}</p>}

      {events.data.map((e) => (
        <div key={e.id} className="card p-4">
          <Link href={`/events/${e.id}`} className="font-bold text-text-primary hover:underline">{e.title}</Link>
          <p className="text-xs text-text-secondary">
            {formatDateTime(e.eventDate)} · {e.currentRegistrations}/{e.maxCapacity} registered
          </p>
          {e.sentiment && (
            <div className="mt-3">
              <p className="flex items-center gap-1.5 text-sm font-semibold text-text-primary">Feedback sentiment <AiBadge /></p>
              <div className="mt-2 flex h-2.5 overflow-hidden rounded-full bg-primary-container">
                <div className="bg-success" style={{ width: `${e.sentiment.positive}%` }} />
                <div className="bg-warning" style={{ width: `${e.sentiment.neutral}%` }} />
                <div className="bg-error" style={{ width: `${e.sentiment.negative}%` }} />
              </div>
              <p className="mt-1.5 text-xs text-text-secondary">
                {e.sentiment.positive}% positive · {e.sentiment.neutral}% neutral · {e.sentiment.negative}% negative
              </p>
            </div>
          )}
          <button type="button" className="btn-outline mt-3" onClick={() => runRollup(e.id, e.title)} disabled={running === e.id}>
            <Sparkles size={16} aria-hidden />
            {running === e.id ? "Analysing…" : e.sentiment ? "Refresh sentiment" : "Run sentiment rollup"}
          </button>
        </div>
      ))}
    </div>
  );
}
