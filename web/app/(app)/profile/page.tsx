"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import {
  addDoc, collection, collectionGroup, doc, getDoc, getDocs, orderBy, query, serverTimestamp, where,
} from "firebase/firestore";
import { CalendarCheck, Edit, LogOut, Megaphone, ShieldCheck, Ticket, UploadCloud } from "lucide-react";
import { db } from "@/lib/firebase/firebase";
import { logout, useAuth } from "@/lib/auth-context";
import { friendlyError } from "@/lib/errors";
import { useLiveQuery } from "@/lib/hooks";
import {
  ROLE_LABELS, canBuildEvents, eventIsPast, formatDateTime, isStaff, toAttendance, toEvent, toFrame, toProject,
  type EventItem,
} from "@/lib/models";
import { Avatar, EmptyState, ErrorText, PageHeader, PageSpinner, TagChip } from "@/components/ui";

type Tab = "tickets" | "uploads" | "attendance";

function useMyTickets(uid: string | undefined, enabled: boolean) {
  const [events, setEvents] = useState<EventItem[] | null>(null);
  const [error, setError] = useState("");
  useEffect(() => {
    if (!uid || !enabled) return;
    (async () => {
      try {
        const regs = await getDocs(
          query(collectionGroup(db, "registrations"), where("studentUid", "==", uid), orderBy("registeredAt", "desc")),
        );
        const snaps = await Promise.all(
          regs.docs.map((r) => getDoc(doc(db, "events", (r.data().eventId as string) ?? r.ref.parent.parent!.id))),
        );
        setEvents(snaps.filter((s) => s.exists()).map((s) => toEvent(s.id, s.data()!)));
      } catch (err) {
        setError(friendlyError(err));
        setEvents([]);
      }
    })();
  }, [uid, enabled]);
  return { events, error };
}

export default function ProfilePage() {
  const { profile } = useAuth();
  const isStudent = profile?.role === "student";
  const [tab, setTab] = useState<Tab>("tickets");
  const activeTab: Tab = isStudent ? tab : "uploads";

  const tickets = useMyTickets(profile?.uid, isStudent);
  const frames = useLiveQuery(
    () => (profile ? query(collection(db, "memoryFrames"), where("uploadedBy", "==", profile.uid), orderBy("createdAt", "desc")) : null),
    toFrame,
    [profile?.uid],
  );
  const projects = useLiveQuery(
    () => (profile && isStudent ? query(collection(db, "projects"), where("ownerUid", "==", profile.uid), orderBy("createdAt", "desc")) : null),
    toProject,
    [profile?.uid, isStudent],
  );
  const attendance = useLiveQuery(
    () => (profile && isStudent ? query(collection(db, "attendanceRequests"), where("studentId", "==", profile.uid)) : null),
    toAttendance,
    [profile?.uid, isStudent],
  );

  const [requestEvent, setRequestEvent] = useState("");
  const [requestDetails, setRequestDetails] = useState("");
  const [requestError, setRequestError] = useState("");
  const [requestSent, setRequestSent] = useState(false);

  if (!profile) return <PageSpinner />;

  const details =
    profile.role === "student"
      ? [`USN ${profile.usn}`, profile.yearOfStudy && `${profile.yearOfStudy} Year`, profile.batch]
      : [profile.designation ?? ROLE_LABELS[profile.role], profile.club, profile.facultyId && `ID ${profile.facultyId}`];

  const submitRequest = async (e: React.FormEvent) => {
    e.preventDefault();
    setRequestError("");
    setRequestSent(false);
    if (!requestEvent) return setRequestError("Choose the event this request is for.");
    if (requestDetails.trim().length < 10) return setRequestError("Please add a little more detail.");
    try {
      await addDoc(collection(db, "attendanceRequests"), {
        studentId: profile.uid,
        eventId: requestEvent,
        requestDetails: requestDetails.trim(),
        status: "pending",
        createdAt: serverTimestamp(),
      });
      setRequestDetails("");
      setRequestSent(true);
    } catch (err) {
      setRequestError(friendlyError(err));
    }
  };

  const tabs: { id: Tab; label: string; icon: typeof Ticket }[] = isStudent
    ? [
        { id: "tickets", label: "My Tickets", icon: Ticket },
        { id: "uploads", label: "My Uploads", icon: UploadCloud },
        { id: "attendance", label: "Attendance", icon: CalendarCheck },
      ]
    : [{ id: "uploads", label: "My Uploads", icon: UploadCloud }];

  const eventTitle = (id: string) => tickets.events?.find((t) => t.id === id)?.title ?? "Event";
  const sortedAttendance = [...attendance.data].sort((a, b) => (b.createdAt?.getTime() ?? 0) - (a.createdAt?.getTime() ?? 0));

  return (
    <div className="flex flex-col">
      <PageHeader title="My Dashboard" />

      <div className="px-5 py-3">
        <div className="card flex items-center gap-5 p-5">
          <Avatar name={profile.fullName} url={profile.profilePictureUrl} size={72} />
          <div className="min-w-0 flex-1">
            <h2 className="truncate text-[20px] font-extrabold text-text-primary">{profile.fullName}</h2>
            <div className="mt-1"><TagChip label={ROLE_LABELS[profile.role]} /></div>
            <p className="mt-1 text-[13px] text-text-secondary">{details.filter(Boolean).join(" · ")}</p>
            {profile.status === "pending_batch_review" && (
              <p className="text-xs text-warning">Batch details pending HOD review</p>
            )}
          </div>
        </div>
      </div>

      <div className="flex flex-wrap gap-2 px-5 py-2">
        <Link href="/profile/edit" className="btn-primary px-5 py-2.5 text-sm"><Edit size={16} aria-hidden /> Edit Profile</Link>
        {isStaff(profile.role) && <Link href="/updates/new" className="btn-outline"><Megaphone size={16} aria-hidden /> Post Update</Link>}
        {canBuildEvents(profile.role) && <Link href="/admin" className="btn-outline"><ShieldCheck size={16} aria-hidden /> Admin Panel</Link>}
        <button type="button" onClick={() => confirm("Log out of AIKYA?") && logout()} className="btn-outline text-error">
          <LogOut size={16} aria-hidden /> Logout
        </button>
      </div>

      <div role="tablist" className="mx-5 mt-4 flex border-b-2 border-border">
        {tabs.map((t) => (
          <button
            key={t.id}
            role="tab"
            aria-selected={activeTab === t.id}
            onClick={() => setTab(t.id)}
            className={`-mb-0.5 flex flex-1 items-center justify-center gap-2 border-b-2 py-3 text-[13px] ${
              activeTab === t.id ? "border-accent font-bold text-text-primary" : "border-transparent font-medium text-text-tertiary"
            }`}
          >
            <t.icon size={16} aria-hidden /> {t.label}
          </button>
        ))}
      </div>

      <div className="flex flex-col gap-3 px-5 pt-5 pb-8">
        {activeTab === "tickets" &&
          (!tickets.events ? (
            <PageSpinner />
          ) : tickets.events.length === 0 ? (
            <EmptyState icon={Ticket} message={tickets.error || "No tickets yet. Register for an event from the Events Hub."} action={<Link href="/events" className="btn-outline">Browse events</Link>} />
          ) : (
            tickets.events.map((e) => (
              <Link key={e.id} href={`/events/${e.id}`} className="card flex items-center gap-4 p-4 transition hover:border-accent/50">
                <div className="min-w-0 flex-1">
                  <TagChip label={eventIsPast(e) ? "Past" : "Upcoming"} tone={eventIsPast(e) ? "muted" : "accent"} />
                  <h3 className="mt-2 font-bold text-text-primary">{e.title}</h3>
                  <p className="text-xs text-text-secondary">{formatDateTime(e.eventDate)}</p>
                  <p className="text-xs text-text-secondary">{e.venue}</p>
                  <p className="mt-2 text-[11px] font-semibold tracking-widest text-text-tertiary">
                    REGISTRATION #{e.id.slice(0, 6).toUpperCase()}
                  </p>
                </div>
              </Link>
            ))
          ))}

        {activeTab === "uploads" && (
          <>
            {projects.data.length === 0 && frames.data.length === 0 ? (
              <EmptyState
                icon={UploadCloud}
                message={isStudent ? "Nothing uploaded yet. Submit a project or share a memory." : "Nothing uploaded yet. Share a memory from the Memory Wall."}
                action={<Link href="/memory" className="btn-outline">Open Memory Wall</Link>}
              />
            ) : (
              <>
                {projects.data.length > 0 && <h3 className="font-bold text-text-primary">Projects</h3>}
                {projects.data.map((p) => (
                  <Link key={p.id} href={`/projects/${p.id}`} className="card p-4 transition hover:border-accent/50">
                    <p className="font-semibold text-text-primary">{p.title}</p>
                    <p className="text-xs text-text-tertiary">{p.techStack.join(", ")}</p>
                  </Link>
                ))}
                {frames.data.length > 0 && <h3 className="mt-2 font-bold text-text-primary">Memory Wall uploads</h3>}
                <div className="grid grid-cols-3 gap-2">
                  {frames.data.map((f) => (
                    <div key={f.id} className="relative aspect-square overflow-hidden rounded-md">
                      {/* eslint-disable-next-line @next/next/no-img-element */}
                      <img src={f.imageUrl} alt={f.caption || "Upload"} className="h-full w-full object-cover" />
                      <span className="absolute bottom-1 left-1">
                        <TagChip label={f.status} tone={f.status === "approved" ? "success" : f.status === "rejected" ? "error" : "warning"} />
                      </span>
                    </div>
                  ))}
                </div>
              </>
            )}
          </>
        )}

        {activeTab === "attendance" && (
          <>
            <form onSubmit={submitRequest} className="card flex flex-col gap-3 p-4">
              <h3 className="font-bold text-text-primary">New attendance / OD request</h3>
              <select aria-label="Event" className="input" value={requestEvent} onChange={(e) => setRequestEvent(e.target.value)}>
                <option value="">Choose one of your events</option>
                {(tickets.events ?? []).map((e) => (
                  <option key={e.id} value={e.id}>{e.title}</option>
                ))}
              </select>
              <textarea aria-label="Details" className="input" rows={3} maxLength={500} placeholder="Which classes did you miss and why?" value={requestDetails} onChange={(e) => setRequestDetails(e.target.value)} />
              <ErrorText message={requestError} />
              {requestSent && <p role="status" className="text-sm font-semibold text-success">Request sent to the HOD for review.</p>}
              <button type="submit" className="btn-primary self-start">Submit request</button>
            </form>
            {sortedAttendance.length === 0 ? (
              <EmptyState icon={CalendarCheck} message={attendance.error || "No attendance requests yet."} />
            ) : (
              sortedAttendance.map((r) => (
                <div key={r.id} className="card p-4">
                  <div className="flex items-center justify-between gap-3">
                    <h3 className="font-bold text-text-primary">{eventTitle(r.eventId)}</h3>
                    <TagChip label={r.status} tone={r.status === "approved" ? "success" : r.status === "rejected" ? "error" : "warning"} />
                  </div>
                  <p className="mt-2 text-[13px] text-text-secondary">{r.requestDetails}</p>
                  {r.reviewNotes && <p className="mt-2 text-xs text-text-tertiary italic">HOD note: {r.reviewNotes}</p>}
                </div>
              ))
            )}
          </>
        )}
      </div>
    </div>
  );
}
