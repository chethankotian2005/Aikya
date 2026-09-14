"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import {
  addDoc, collection, deleteDoc, doc, increment, limit, orderBy, query, runTransaction, serverTimestamp,
} from "firebase/firestore";
import { CalendarX, CheckCircle, Clock, Flag, MapPin, Send, Trash2, Users } from "lucide-react";
import { db } from "@/lib/firebase/firebase";
import { useAuth } from "@/lib/auth-context";
import { friendlyError } from "@/lib/errors";
import { useLiveDoc, useLiveQuery } from "@/lib/hooks";
import {
  eventFillRatio, eventIsFull, eventIsOpen, eventIsPast, formatDateTime, isStaff, timeAgo, toComment, toEvent,
  type EventItem, type RegistrationField,
} from "@/lib/models";
import { AiBadge, Avatar, BannerImage, EmptyState, ErrorText, PageHeader, PageSpinner, TagChip } from "@/components/ui";
import Markdown from "@/components/Markdown";

function Countdown({ target }: { target: Date }) {
  const [now, setNow] = useState(() => Date.now());
  useEffect(() => {
    const t = setInterval(() => setNow(Date.now()), 1000);
    return () => clearInterval(t);
  }, []);
  const ms = target.getTime() - now;
  if (ms <= 0) return null;
  const parts: [number, string][] = [
    [Math.floor(ms / 86_400_000), "D"],
    [Math.floor(ms / 3_600_000) % 24, "H"],
    [Math.floor(ms / 60_000) % 60, "M"],
    [Math.floor(ms / 1000) % 60, "S"],
  ];
  return (
    <div className="flex items-center gap-3 rounded-lg bg-brand-gradient px-4 py-3 text-white">
      <Clock size={18} className="text-accent" aria-hidden />
      <span className="text-xs text-white/70">Starts in</span>
      <div className="ml-auto flex gap-3" aria-live="off">
        {parts.map(([v, l]) => (
          <div key={l} className="text-center">
            <div className="text-lg leading-tight font-extrabold">{String(v).padStart(2, "0")}</div>
            <div className="text-[9px] font-semibold text-accent">{l}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

function FieldInput({ field, value, onChange }: { field: RegistrationField; value: string; onChange: (v: string) => void }) {
  const id = `field-${field.label.replace(/\W+/g, "-")}`;
  const label = (
    <label htmlFor={id} className="label">
      {field.label} {field.required && <span className="text-error">*</span>}
    </label>
  );
  if (field.type === "dropdown") {
    return (
      <div>
        {label}
        <select id={id} className="input" value={value} onChange={(e) => onChange(e.target.value)} required={field.required}>
          <option value="">{field.hint || "Select"}</option>
          {field.options.map((o) => (
            <option key={o} value={o}>{o}</option>
          ))}
        </select>
      </div>
    );
  }
  if (field.type === "multiline") {
    return (
      <div>
        {label}
        <textarea id={id} className="input" rows={3} value={value} placeholder={field.hint} onChange={(e) => onChange(e.target.value)} required={field.required} />
      </div>
    );
  }
  return (
    <div>
      {label}
      <input
        id={id}
        className="input"
        type={field.type === "email" ? "email" : field.type === "phone" ? "tel" : "text"}
        value={value}
        placeholder={field.hint}
        onChange={(e) => onChange(e.target.value)}
        required={field.required}
      />
    </div>
  );
}

export default function EventDetail({ id }: { id: string }) {
  const { profile } = useAuth();
  const event = useLiveDoc(() => doc(db, "events", id), toEvent, [id]);
  const registration = useLiveDoc(
    () => (profile ? doc(db, "events", id, "registrations", profile.uid) : null),
    (docId) => docId,
    [id, profile?.uid],
  );
  const comments = useLiveQuery(
    () => query(collection(db, "events", id, "comments"), orderBy("createdAt", "desc"), limit(50)),
    toComment,
    [id],
  );

  const [answers, setAnswers] = useState<Record<string, string>>({});
  const [comment, setComment] = useState("");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");
  const [notice, setNotice] = useState("");

  if (event.loading || !profile) return <PageSpinner />;
  const e = event.data;
  if (!e) {
    return (
      <>
        <PageHeader title="Event" back />
        <EmptyState icon={CalendarX} message={event.error || "This event no longer exists."} />
      </>
    );
  }

  const isStudent = profile.role === "student";
  const canManage = profile.role === "hod" || (profile.role === "coordinator" && e.createdBy === profile.uid);
  const registered = !!registration.data;
  const past = eventIsPast(e);
  const full = eventIsFull(e);
  const ratio = eventFillRatio(e);

  const register = async (form: React.FormEvent) => {
    form.preventDefault();
    setError("");
    setNotice("");
    setBusy(true);
    try {
      await runTransaction(db, async (tx) => {
        const eventRef = doc(db, "events", id);
        const regRef = doc(db, "events", id, "registrations", profile.uid);
        const snap = await tx.get(eventRef);
        if (!snap.exists()) throw new Error("This event no longer exists.");
        const latest: EventItem = toEvent(id, snap.data());
        if (eventIsPast(latest)) throw new Error("This event has already happened.");
        if (Date.now() > latest.registrationDeadline.getTime()) throw new Error("Registration has closed.");
        if (eventIsFull(latest)) throw new Error("This event is full.");
        if ((await tx.get(regRef)).exists()) throw new Error("You're already registered.");

        tx.set(regRef, {
          studentUid: profile.uid,
          eventId: id,
          formResponses: Object.fromEntries(latest.formFields.map((f) => [f.label, (answers[f.label] ?? "").trim()])),
          registeredAt: serverTimestamp(),
        });
        tx.update(eventRef, { currentRegistrations: increment(1) });
      });
      setNotice("You're registered!");
    } catch (err) {
      setError(friendlyError(err));
    } finally {
      setBusy(false);
    }
  };

  const cancel = async () => {
    if (!confirm(`Cancel your registration for "${e.title}"? Your seat will be released.`)) return;
    setError("");
    setBusy(true);
    try {
      await runTransaction(db, async (tx) => {
        const regRef = doc(db, "events", id, "registrations", profile.uid);
        if (!(await tx.get(regRef)).exists()) throw new Error("You're not registered for this event.");
        tx.delete(regRef);
        tx.update(doc(db, "events", id), { currentRegistrations: increment(-1) });
      });
      setNotice("Registration cancelled.");
    } catch (err) {
      setError(friendlyError(err));
    } finally {
      setBusy(false);
    }
  };

  const postComment = async (form: React.FormEvent) => {
    form.preventDefault();
    const text = comment.trim();
    if (!text) return;
    try {
      await addDoc(collection(db, "events", id, "comments"), {
        userId: profile.uid,
        userName: profile.fullName,
        commentText: text,
        createdAt: serverTimestamp(),
      });
      setComment("");
    } catch (err) {
      setError(friendlyError(err));
    }
  };

  return (
    <div className="flex flex-col">
      <PageHeader title="Event" back />

      <div className="relative mx-5 mt-2 h-52 overflow-hidden rounded-lg">
        <BannerImage url={e.bannerUrl} alt={e.title} className="h-full w-full" />
        <div className="absolute inset-0 bg-gradient-to-t from-primary/80 to-transparent" />
        <div className="absolute right-4 bottom-4 left-4">
          <TagChip label={e.tag} />
          <h2 className="mt-2 text-xl leading-tight font-bold text-white">{e.title}</h2>
        </div>
      </div>

      <div className="flex flex-col gap-4 px-5 pt-4 pb-8">
        {!past && <Countdown target={e.eventDate} />}

        <section className="card divide-y divide-border px-4">
          {[
            [Clock, "When", formatDateTime(e.eventDate) + (e.endDate ? ` – ${formatDateTime(e.endDate)}` : "")],
            [MapPin, "Venue", e.venue],
            [CalendarX, "Registration closes", formatDateTime(e.registrationDeadline)],
            ...(e.club ? [[Flag, "Organised by", e.club] as const] : []),
          ].map(([Icon, label, value]) => (
            <div key={label as string} className="flex items-center gap-3 py-3">
              <div className="flex h-9 w-9 items-center justify-center rounded-md bg-accent/10 text-accent">
                <Icon size={16} aria-hidden />
              </div>
              <div>
                <p className="text-[11px] text-text-tertiary">{label as string}</p>
                <p className="text-sm font-semibold text-text-primary">{value as string}</p>
              </div>
            </div>
          ))}
        </section>

        <section className="card p-4">
          <div className="flex items-center justify-between">
            <h3 className="flex items-center gap-2 text-sm font-semibold text-text-primary">
              <Users size={16} aria-hidden /> Seat availability
            </h3>
            <TagChip label={full ? "Full" : ratio >= 0.8 ? "Filling fast" : "Available"} tone={full ? "error" : ratio >= 0.8 ? "warning" : "success"} />
          </div>
          <p className="mt-3 text-xl font-extrabold text-text-primary">
            {e.currentRegistrations} / {e.maxCapacity} <span className="text-sm font-medium text-text-tertiary">seats filled</span>
          </p>
          <div className="mt-2 h-2 w-full rounded-full bg-primary-container">
            <div className={`h-full rounded-full ${full ? "bg-error" : ratio >= 0.8 ? "bg-warning" : "bg-accent"}`} style={{ width: `${Math.min(ratio * 100, 100)}%` }} />
          </div>
        </section>

        <section className="card p-4">
          <h3 className="text-sm font-bold text-text-primary">About this event</h3>
          <p className="mt-2 text-[13px] leading-relaxed whitespace-pre-line text-text-secondary">
            {e.description || "No description provided."}
          </p>
        </section>

        {notice && <p role="status" className="rounded-lg bg-success/10 px-4 py-3 text-sm font-semibold text-success">{notice}</p>}
        <ErrorText message={error} />

        {isStudent && registered && (
          <section className="flex items-center gap-3 rounded-lg border border-success/25 bg-success/8 p-4">
            <CheckCircle className="text-success" aria-hidden />
            <p className="flex-1 text-sm font-semibold text-success">You&apos;re registered for this event.</p>
            {!past && (
              <button type="button" onClick={cancel} disabled={busy} className="text-sm font-semibold text-error hover:underline">
                Cancel
              </button>
            )}
          </section>
        )}

        {isStudent && !registered && (
          eventIsOpen(e) ? (
            <form onSubmit={register} className="card flex flex-col gap-4 p-4">
              {e.formFields.length > 0 && (
                <>
                  <h3 className="text-sm font-bold text-text-primary">Registration form</h3>
                  {e.formFields.map((f) => (
                    <FieldInput key={f.label} field={f} value={answers[f.label] ?? ""} onChange={(v) => setAnswers((a) => ({ ...a, [f.label]: v }))} />
                  ))}
                </>
              )}
              <button type="submit" disabled={busy} className="btn-primary w-full">
                {busy ? "Registering…" : "Register now"}
              </button>
            </form>
          ) : (
            <p className="card p-4 text-center text-sm text-text-secondary">
              {past ? "This event has ended." : full ? "This event is full." : "Registration has closed."}
            </p>
          )
        )}

        {!isStudent && !canManage && (
          <p className="text-center text-xs text-text-tertiary italic">Faculty view — registration not applicable.</p>
        )}

        {canManage && (
          <div className="flex flex-wrap gap-2">
            <Link href={`/admin/events/${id}/edit`} className="btn-outline">Edit event</Link>
            <Link href={`/admin/reports?eventId=${id}`} className="btn-primary">Generate report</Link>
          </div>
        )}

        {isStaff(profile.role) && e.sentiment && (
          <section className="card p-4">
            <h3 className="flex items-center gap-2 text-sm font-bold text-text-primary">Feedback sentiment <AiBadge /></h3>
            {(["positive", "neutral", "negative"] as const).map((k) => (
              <div key={k} className="mt-2 flex items-center gap-3 text-xs">
                <span className="w-16 capitalize text-text-secondary">{k}</span>
                <div className="h-2 flex-1 rounded-full bg-primary-container">
                  <div
                    className={`h-full rounded-full ${k === "positive" ? "bg-success" : k === "neutral" ? "bg-warning" : "bg-error"}`}
                    style={{ width: `${e.sentiment![k] ?? 0}%` }}
                  />
                </div>
                <span className="w-10 text-right">{e.sentiment![k] ?? 0}%</span>
              </div>
            ))}
          </section>
        )}

        {isStaff(profile.role) && e.reportMarkdown && (
          <section className="card p-4">
            <h3 className="mb-2 flex items-center gap-2 text-sm font-bold text-text-primary">Event report <AiBadge /></h3>
            <Markdown>{e.reportMarkdown}</Markdown>
          </section>
        )}

        <section className="card p-4">
          <h3 className="text-sm font-bold text-text-primary">Feedback &amp; comments</h3>
          <form onSubmit={postComment} className="mt-3 flex gap-2">
            <input
              aria-label="Write a comment"
              className="input"
              maxLength={1000}
              placeholder="Share your feedback..."
              value={comment}
              onChange={(ev) => setComment(ev.target.value)}
            />
            <button type="submit" aria-label="Post comment" className="btn-primary px-4" disabled={!comment.trim()}>
              <Send size={16} />
            </button>
          </form>
          <ul className="mt-4 flex flex-col gap-3">
            {comments.data.length === 0 && (
              <li className="text-xs text-text-tertiary">No comments yet — be the first to share feedback.</li>
            )}
            {comments.data.map((c) => (
              <li key={c.id} className="flex gap-3">
                <Avatar name={c.userName} size={32} />
                <div className="min-w-0 flex-1">
                  <p className="text-xs font-semibold text-text-primary">
                    {c.userName} <span className="font-normal text-text-tertiary">· {timeAgo(c.createdAt)}</span>
                  </p>
                  <p className="text-[13px] break-words text-text-secondary">{c.commentText}</p>
                </div>
                {(c.userId === profile.uid || canManage) && (
                  <button
                    type="button"
                    aria-label="Delete comment"
                    onClick={() => deleteDoc(doc(db, "events", id, "comments", c.id)).catch((err) => setError(friendlyError(err)))}
                    className="text-text-tertiary hover:text-error"
                  >
                    <Trash2 size={16} />
                  </button>
                )}
              </li>
            ))}
          </ul>
        </section>
      </div>
    </div>
  );
}
