import Link from "next/link";
import { Calendar as CalendarIcon, CheckCircle, MapPin } from "lucide-react";
import { eventFillRatio, eventIsFull, eventIsPast, formatDateTime, monthShort, type EventItem } from "@/lib/models";
import { BannerImage, TagChip } from "@/components/ui";

/** Full-width event card used by the Events Hub. */
export function EventCard({ event, registered = false }: { event: EventItem; registered?: boolean }) {
  const ratio = eventFillRatio(event);
  const full = eventIsFull(event);
  const near = ratio >= 0.8 && !full;
  const past = eventIsPast(event);
  const barColor = full ? "bg-error" : near ? "bg-warning" : "bg-accent";

  return (
    <Link href={`/events/${event.id}`} className="card block overflow-hidden transition hover:border-accent/50">
      <div className="relative h-36 w-full">
        <BannerImage url={event.bannerUrl} alt={event.title} className="h-full w-full" />
        <div className="absolute top-2.5 left-2.5 flex min-w-[40px] flex-col items-center rounded-md bg-surface-elevated px-2 py-1 shadow-sm">
          <span className="text-base leading-tight font-extrabold text-text-primary">{event.eventDate.getDate()}</span>
          <span className="text-[9px] font-semibold tracking-widest text-accent">{monthShort(event.eventDate)}</span>
        </div>
        {past ? (
          <span className="absolute top-2.5 right-2.5 rounded-full bg-primary/80 px-2.5 py-1 text-[10px] font-semibold text-white/80">PAST</span>
        ) : registered ? (
          <span className="absolute top-2.5 right-2.5 flex items-center gap-1 rounded-full bg-success/90 px-2.5 py-1 text-[10px] font-semibold text-white">
            <CheckCircle size={12} aria-hidden /> REGISTERED
          </span>
        ) : null}
      </div>
      <div className="p-4">
        <TagChip label={event.tag} />
        <h3 className="mt-2 line-clamp-2 text-[15px] leading-snug font-bold text-text-primary">{event.title}</h3>
        <p className="mt-2.5 flex items-center gap-2 text-xs text-text-secondary">
          <CalendarIcon size={14} aria-hidden /> {formatDateTime(event.eventDate)}
        </p>
        <p className="mt-1.5 flex items-center gap-2 truncate text-xs text-text-secondary">
          <MapPin size={14} aria-hidden /> {event.venue}
        </p>
        <div className="mt-3 flex items-center justify-between text-xs font-semibold">
          <span className={full ? "text-error" : near ? "text-warning" : "text-accent"}>
            {event.currentRegistrations}/{event.maxCapacity} seats
          </span>
          {full ? <span className="text-error">Full</span> : near ? <span className="text-warning">Filling fast</span> : null}
        </div>
        <div className="mt-1.5 h-1.5 w-full rounded-full bg-primary-container">
          <div className={`h-full rounded-full ${barColor}`} style={{ width: `${Math.min(ratio * 100, 100)}%` }} />
        </div>
      </div>
    </Link>
  );
}

/** Compact card for the Home carousel. */
export function EventMiniCard({ event }: { event: EventItem }) {
  const full = eventIsFull(event);
  return (
    <Link href={`/events/${event.id}`} className="card flex w-[260px] shrink-0 flex-col overflow-hidden transition hover:border-accent/50">
      <div className="relative h-[120px] w-full">
        <BannerImage url={event.bannerUrl} alt={event.title} className="h-full w-full" />
        <div className="absolute top-2 left-2 flex min-w-[36px] flex-col items-center rounded-md bg-surface-elevated px-2 py-1 shadow-sm">
          <span className="text-base leading-tight font-extrabold text-text-primary">{event.eventDate.getDate()}</span>
          <span className="text-[9px] font-semibold tracking-widest text-accent">{monthShort(event.eventDate)}</span>
        </div>
        <span className="absolute right-2 bottom-2 rounded-full bg-primary/75 px-2.5 py-1 text-[11px] font-semibold text-white">
          {full ? "Full" : `${event.currentRegistrations}/${event.maxCapacity} seats`}
        </span>
      </div>
      <div className="flex flex-col gap-1.5 p-3.5">
        <TagChip label={event.tag} />
        <h4 className="line-clamp-2 text-sm leading-tight font-bold text-text-primary">{event.title}</h4>
        <p className="truncate text-[11px] text-text-tertiary">{event.venue}</p>
      </div>
    </Link>
  );
}
