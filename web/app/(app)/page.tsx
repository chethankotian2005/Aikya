"use client";

import { useEffect, useState } from "react";
import Image from "next/image";
import Link from "next/link";
import {
  Timestamp, collection, getCountFromServer, limit, orderBy, query, where, type Query,
} from "firebase/firestore";
import {
  Calendar, CalendarClock, FolderOpen, GraduationCap, Image as ImageIcon, LayoutDashboard, Megaphone, ShieldCheck, Users,
} from "lucide-react";
import { db } from "@/lib/firebase/firebase";
import { useAuth } from "@/lib/auth-context";
import { useLiveQuery } from "@/lib/hooks";
import { ROLE_LABELS, canBuildEvents, formatDate, isStaff, timeAgo, toEvent, toUpdate } from "@/lib/models";
import { Avatar, EmptyState, PageSpinner, TagChip } from "@/components/ui";
import { EventMiniCard } from "@/components/EventCard";

const countOf = async (q: Query) => (await getCountFromServer(q)).data().count;

export default function Home() {
  const { profile } = useAuth();
  const [stats, setStats] = useState<number[] | null>(null);

  useEffect(() => {
    Promise.all([
      countOf(collection(db, "projects")),
      countOf(query(collection(db, "events"), where("eventDate", ">=", Timestamp.now()))),
      countOf(query(collection(db, "users"), where("role", "==", "student"))),
      countOf(collection(db, "alumniProfiles")),
    ])
      .then(setStats)
      .catch(() => setStats(null));
  }, []);

  const events = useLiveQuery(
    () => query(collection(db, "events"), where("eventDate", ">=", Timestamp.now()), orderBy("eventDate"), limit(6)),
    toEvent,
    [],
  );
  const updates = useLiveQuery(
    () => query(collection(db, "updates"), orderBy("createdAt", "desc"), limit(20)),
    toUpdate,
    [],
  );

  if (!profile) return <PageSpinner />;

  const hour = new Date().getHours();
  const greeting = hour < 12 ? "Good morning" : hour < 17 ? "Good afternoon" : "Good evening";
  const subtitle =
    profile.role === "student" ? profile.usn : [ROLE_LABELS[profile.role], profile.club].filter(Boolean).join(" · ");

  const statPills = [
    { icon: FolderOpen, label: "Projects", tone: "text-accent bg-accent/10" },
    { icon: Calendar, label: "Upcoming Events", tone: "text-secondary bg-secondary/10" },
    { icon: Users, label: "Students", tone: "text-success bg-success/10" },
    { icon: GraduationCap, label: "Alumni", tone: "text-warning bg-warning/10" },
  ];

  const actions = [
    { href: "/memory", icon: ImageIcon, label: "Memory Wall", show: true },
    { href: "/updates/new", icon: Megaphone, label: "Post Update", show: isStaff(profile.role) },
    { href: "/admin", icon: ShieldCheck, label: "Admin Panel", show: canBuildEvents(profile.role) },
    { href: "/profile", icon: LayoutDashboard, label: "My Dashboard", show: true },
  ].filter((a) => a.show);

  return (
    <div className="flex flex-col">
      <header className="flex items-center gap-4 px-5 pt-5 pb-2">
        <Link href="/profile" aria-label="Open my dashboard">
          <Avatar name={profile.fullName} url={profile.profilePictureUrl} />
        </Link>
        <div className="min-w-0 flex-1">
          <p className="text-xs font-medium text-text-tertiary">{greeting}</p>
          <h1 className="truncate text-lg leading-tight font-bold tracking-tight text-text-primary">{profile.fullName}</h1>
          {subtitle && <p className="truncate text-[11px] text-text-secondary">{subtitle}</p>}
        </div>
        <Image src="/aikya_logo_cropped.png" alt="AIKYA" width={40} height={40} className="object-contain" />
      </header>

      <div className="no-scrollbar w-full overflow-x-auto pt-2 pb-2">
        <div className="flex min-w-max gap-3 px-5">
          {statPills.map((s, i) => (
            <div key={s.label} className="flex shrink-0 items-center gap-2.5 rounded-full border border-border bg-surface-elevated px-3.5 py-1.5 shadow-sm">
              <div className={`flex h-7 w-7 items-center justify-center rounded-full ${s.tone}`}>
                <s.icon size={14} aria-hidden />
              </div>
              <div>
                <div className="text-[15px] leading-tight font-bold text-text-primary">{stats ? stats[i] : "–"}</div>
                <div className="text-[10px] font-medium text-text-tertiary">{s.label}</div>
              </div>
            </div>
          ))}
        </div>
      </div>

      <div className="flex flex-wrap gap-2 px-5 pt-2">
        {actions.map((a) => (
          <Link
            key={a.href}
            href={a.href}
            className="flex items-center gap-2 rounded-full border border-border bg-surface-elevated px-4 py-2 text-xs font-semibold text-text-primary transition hover:border-accent"
          >
            <a.icon size={16} className="text-secondary" aria-hidden /> {a.label}
          </Link>
        ))}
      </div>

      <div className="flex items-center justify-between px-5 pt-6 pb-3">
        <h2 className="text-[15px] font-bold text-text-primary">Upcoming Events</h2>
        <Link href="/events" className="text-xs font-semibold text-secondary hover:underline">
          View all
        </Link>
      </div>
      {events.loading ? (
        <PageSpinner />
      ) : events.data.length === 0 ? (
        <EmptyState icon={Calendar} message={events.error || "No upcoming events yet."} />
      ) : (
        <div className="no-scrollbar w-full overflow-x-auto pb-2">
          <div className="flex min-w-max gap-4 px-5">
            {events.data.map((e) => (
              <EventMiniCard key={e.id} event={e} />
            ))}
          </div>
        </div>
      )}

      <h2 className="px-5 pt-6 pb-3 text-[15px] font-bold text-text-primary">Department Updates</h2>
      <div className="flex flex-col gap-4 px-5 pb-6">
        {updates.loading ? (
          <PageSpinner />
        ) : updates.data.length === 0 ? (
          <EmptyState icon={Megaphone} message={updates.error || "No department updates yet."} />
        ) : (
          updates.data.map((u) => (
            <article key={u.id} className="card p-4">
              <div className="flex items-center gap-3">
                <Avatar name={u.authorName} size={36} />
                <div className="min-w-0 flex-1">
                  <div className="flex items-center gap-2">
                    <h3 className="truncate text-sm font-semibold text-text-primary">{u.authorName}</h3>
                    {u.club && <TagChip label={u.club} />}
                  </div>
                  <p className="text-[11px] text-text-tertiary">
                    {u.authorDesignation} · {timeAgo(u.createdAt)}
                  </p>
                </div>
              </div>
              <p className="mt-3 text-[13px] leading-relaxed whitespace-pre-line text-text-secondary">{u.content}</p>
              {u.imageUrl && (
                // eslint-disable-next-line @next/next/no-img-element
                <img src={u.imageUrl} alt="" className="mt-3 w-full rounded-lg object-cover" />
              )}
              {u.deadlineDate && (
                <p className="mt-3 flex items-center gap-2 rounded-lg border border-warning/30 bg-warning/10 px-3 py-2 text-xs font-semibold text-warning">
                  <CalendarClock size={16} aria-hidden /> Deadline: {formatDate(u.deadlineDate)}
                </p>
              )}
            </article>
          ))
        )}
      </div>
    </div>
  );
}
