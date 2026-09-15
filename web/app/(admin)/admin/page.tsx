"use client";

import { useEffect, useState } from "react";
import { Timestamp, collection, getCountFromServer, query, where, type Query } from "firebase/firestore";
import { CalendarCheck, CalendarDays, Flag, FolderOpen, ShieldAlert, ClipboardCheck, Users, type LucideIcon } from "lucide-react";
import { db } from "@/lib/firebase/firebase";
import { useAuth } from "@/lib/auth-context";
import { friendlyError } from "@/lib/errors";
import { ErrorText, PageSpinner } from "@/components/ui";

type Stat = { label: string; value: number; icon: LucideIcon; tone: string };

const countOf = async (q: Query) => (await getCountFromServer(q)).data().count;

export default function AdminDashboard() {
  const { profile } = useAuth();
  const [stats, setStats] = useState<Stat[] | null>(null);
  const [error, setError] = useState("");

  useEffect(() => {
    if (!profile) return;
    const now = Timestamp.now();
    const events = collection(db, "events");

    const load = async (): Promise<Stat[]> => {
      if (profile.role === "hod") {
        const [upcoming, eventApprovals, moderation, students, reviews, projects] = await Promise.all([
          countOf(query(events, where("status", "==", "approved"), where("eventDate", ">=", now))),
          countOf(query(events, where("status", "==", "pending"))),
          countOf(query(collection(db, "memoryFrames"), where("status", "==", "pending"))),
          countOf(query(collection(db, "users"), where("role", "==", "student"))),
          countOf(query(collection(db, "users"), where("status", "==", "pending_batch_review"))),
          countOf(collection(db, "projects")),
        ]);
        return [
          { label: "Upcoming events", value: upcoming, icon: CalendarCheck, tone: "text-accent bg-accent/15" },
          { label: "Event approvals", value: eventApprovals, icon: ClipboardCheck, tone: "text-error bg-error/15" },
          { label: "Moderation queue", value: moderation, icon: ShieldAlert, tone: "text-error bg-error/15" },
          { label: "Students", value: students, icon: Users, tone: "text-success bg-success/15" },
          { label: "Batch reviews", value: reviews, icon: Flag, tone: "text-warning bg-warning/15" },
          { label: "Projects", value: projects, icon: FolderOpen, tone: "text-secondary bg-secondary/15" },
        ];
      }
      const mine = query(events, where("createdBy", "==", profile.uid));
      const [total, upcoming] = await Promise.all([countOf(mine), countOf(query(mine, where("eventDate", ">=", now)))]);
      return [
        { label: "My events", value: total, icon: CalendarDays, tone: "text-accent bg-accent/15" },
        { label: "Upcoming", value: upcoming, icon: CalendarCheck, tone: "text-success bg-success/15" },
      ];
    };

    load().then(setStats).catch((err) => setError(friendlyError(err)));
  }, [profile]);

  return (
    <div className="p-5">
      <h2 className="text-2xl font-extrabold tracking-tight text-text-primary">Overview</h2>
      <p className="mt-1 text-[13px] text-text-secondary">Live department status.</p>
      <div className="mt-6">
        <ErrorText message={error} />
        {!stats && !error ? (
          <PageSpinner />
        ) : (
          <div className="grid grid-cols-2 gap-4 sm:grid-cols-3">
            {stats?.map((s) => (
              <div key={s.label} className="card flex aspect-[1.2] flex-col justify-between p-4">
                <div className={`flex h-11 w-11 items-center justify-center rounded-full ${s.tone}`}>
                  <s.icon size={22} aria-hidden />
                </div>
                <div>
                  <p className="text-[28px] leading-tight font-extrabold text-text-primary">{s.value}</p>
                  <p className="text-xs font-semibold text-text-secondary">{s.label}</p>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
