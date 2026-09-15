"use client";

import { useEffect, useMemo, useState } from "react";
import {
  Timestamp, collection, collectionGroup, doc, getDoc, getDocs, limit, orderBy, query, where,
} from "firebase/firestore";
import { CalendarX, Search, X } from "lucide-react";
import { db } from "@/lib/firebase/firebase";
import { useAuth } from "@/lib/auth-context";
import { friendlyError } from "@/lib/errors";
import { useLiveQuery } from "@/lib/hooks";
import { eventOpenToYear, toEvent, type EventItem } from "@/lib/models";
import { EmptyState, PageHeader, PageSpinner } from "@/components/ui";
import { EventCard } from "@/components/EventCard";

type Segment = "upcoming" | "past" | "mine";

export default function EventsHub() {
  const { profile } = useAuth();
  const isStudent = profile?.role === "student";
  const [segment, setSegment] = useState<Segment>("upcoming");
  const [search, setSearch] = useState("");
  const [pageSize, setPageSize] = useState(20);
  const [mine, setMine] = useState<{ events: EventItem[]; loading: boolean; error: string }>({
    events: [],
    loading: true,
    error: "",
  });

  const events = useLiveQuery(
    () => {
      if (segment === "mine") return null;
      const now = Timestamp.now();
      const approved = query(collection(db, "events"), where("status", "==", "approved"));
      return segment === "upcoming"
        ? query(approved, where("eventDate", ">=", now), orderBy("eventDate"), limit(pageSize))
        : query(approved, where("eventDate", "<", now), orderBy("eventDate", "desc"), limit(pageSize));
    },
    toEvent,
    [segment, pageSize],
  );

  useEffect(() => {
    if (!profile || !isStudent) return;
    (async () => {
      try {
        const regs = await getDocs(
          query(collectionGroup(db, "registrations"), where("studentUid", "==", profile.uid), orderBy("registeredAt", "desc")),
        );
        const snaps = await Promise.all(
          regs.docs.map((r) => getDoc(doc(db, "events", (r.data().eventId as string) ?? r.ref.parent.parent!.id))),
        );
        setMine({ events: snaps.filter((s) => s.exists()).map((s) => toEvent(s.id, s.data()!)), loading: false, error: "" });
      } catch (err) {
        setMine({ events: [], loading: false, error: friendlyError(err) });
      }
    })();
  }, [profile, isStudent]);

  const registeredIds = useMemo(() => new Set(mine.events.map((e) => e.id)), [mine.events]);
  // "Mine" is the student's own registrations — those stay visible even if
  // a later year-restriction change would otherwise hide the event.
  const source =
    segment === "mine"
      ? mine.events
      : isStudent
        ? events.data.filter((e) => eventOpenToYear(e, profile?.yearOfStudy ?? null))
        : events.data;
  const loading = segment === "mine" ? mine.loading : events.loading;
  const error = segment === "mine" ? mine.error : events.error;

  const q = search.trim().toLowerCase();
  const visible = q
    ? source.filter((e) => [e.title, e.tag, e.venue].some((v) => v.toLowerCase().includes(q)))
    : source;

  const segments: { id: Segment; label: string }[] = [
    { id: "upcoming", label: "Upcoming" },
    { id: "past", label: "Past" },
    ...(isStudent ? [{ id: "mine" as const, label: "My Registrations" }] : []),
  ];

  return (
    <div className="flex flex-col">
      <PageHeader title="Events Hub" />

      <div className="px-5 pt-3">
        <div className="relative">
          <Search size={18} className="pointer-events-none absolute top-1/2 left-3 -translate-y-1/2 text-text-tertiary" aria-hidden />
          <input
            type="search"
            aria-label="Search events"
            className="input pl-10"
            placeholder="Search events..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
          {search && (
            <button
              type="button"
              aria-label="Clear search"
              onClick={() => setSearch("")}
              className="absolute top-1/2 right-3 -translate-y-1/2 text-text-tertiary hover:text-text-primary"
            >
              <X size={16} />
            </button>
          )}
        </div>
      </div>

      <div className="px-5 pt-4 pb-2">
        <div role="tablist" className="flex rounded-full bg-primary-container p-1">
          {segments.map((s) => (
            <button
              key={s.id}
              role="tab"
              aria-selected={segment === s.id}
              onClick={() => setSegment(s.id)}
              className={`flex-1 rounded-full py-2 text-xs font-semibold transition-all ${
                segment === s.id ? "bg-surface-elevated text-text-primary shadow-sm" : "text-text-tertiary hover:text-text-secondary"
              }`}
            >
              {s.label}
            </button>
          ))}
        </div>
      </div>

      <div className="flex flex-col gap-4 px-5 pt-2 pb-6">
        {loading ? (
          <PageSpinner />
        ) : visible.length === 0 ? (
          <EmptyState
            icon={CalendarX}
            message={
              error ||
              (segment === "mine"
                ? "You haven't registered for any events yet."
                : q
                  ? `No events match "${search}".`
                  : "No events here yet.")
            }
          />
        ) : (
          visible.map((e) => <EventCard key={e.id} event={e} registered={registeredIds.has(e.id)} />)
        )}
        {segment !== "mine" && events.data.length === pageSize && (
          <button type="button" className="btn-outline self-center" onClick={() => setPageSize((n) => n + 20)}>
            Load more
          </button>
        )}
      </div>
    </div>
  );
}
