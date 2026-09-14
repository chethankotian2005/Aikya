"use client";

import Link from "next/link";
import { deleteDoc, doc } from "firebase/firestore";
import { CalendarX, Plus } from "lucide-react";
import { db } from "@/lib/firebase/firebase";
import { useAuth } from "@/lib/auth-context";
import { friendlyError } from "@/lib/errors";
import { eventIsPast, formatDateTime } from "@/lib/models";
import { AiBadge, EmptyState, PageSpinner, TagChip } from "@/components/ui";
import { useManageableEvents } from "@/components/admin/useManageableEvents";

export default function AdminEventsPage() {
  const { profile } = useAuth();
  const events = useManageableEvents(profile);

  const remove = async (id: string, title: string) => {
    if (!confirm(`Delete "${title}"? This cannot be undone.`)) return;
    try {
      await deleteDoc(doc(db, "events", id));
    } catch (err) {
      alert(friendlyError(err));
    }
  };

  return (
    <div className="p-5">
      <div className="mb-5 flex items-center justify-between gap-3">
        <p className="text-sm text-text-secondary">
          {profile?.role === "hod" ? "All department events." : "Events you created."}
        </p>
        <Link href="/admin/events/new" className="btn-primary px-4 py-2.5 text-sm">
          <Plus size={16} aria-hidden /> New event
        </Link>
      </div>

      {events.loading ? (
        <PageSpinner />
      ) : events.data.length === 0 ? (
        <EmptyState icon={CalendarX} message={events.error || "No events yet. Create one to start accepting registrations."} />
      ) : (
        <ul className="flex flex-col gap-3">
          {events.data.map((e) => (
            <li key={e.id} className="card flex flex-col gap-3 p-4 sm:flex-row sm:items-center">
              <div className="min-w-0 flex-1">
                <Link href={`/events/${e.id}`} className="font-bold text-text-primary hover:underline">{e.title}</Link>
                <div className="mt-1.5 flex flex-wrap items-center gap-2 text-xs text-text-secondary">
                  <span>{formatDateTime(e.eventDate)}</span>
                  <TagChip label={eventIsPast(e) ? "Past" : "Upcoming"} tone={eventIsPast(e) ? "muted" : "success"} />
                  <TagChip label={`${e.currentRegistrations}/${e.maxCapacity} seats`} tone="secondary" />
                  {e.reportMarkdown && <AiBadge label="Report ready" />}
                </div>
              </div>
              <div className="flex flex-wrap gap-2">
                <Link href={`/admin/events/${e.id}/edit`} className="btn-outline px-4 py-2">Edit</Link>
                <Link href={`/admin/reports?eventId=${e.id}`} className="btn-outline px-4 py-2">Report</Link>
                <button type="button" onClick={() => remove(e.id, e.title)} className="btn-outline px-4 py-2 text-error">
                  Delete
                </button>
              </div>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
