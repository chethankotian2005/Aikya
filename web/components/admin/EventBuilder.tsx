"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { Timestamp, doc, getDoc, updateDoc } from "firebase/firestore";
import { Plus, Trash2 } from "lucide-react";
import { db } from "@/lib/firebase/firebase";
import { useAuth } from "@/lib/auth-context";
import { callBackend } from "@/lib/api";
import { friendlyError } from "@/lib/errors";
import { CLUBS, toEvent, type FieldType, type RegistrationField } from "@/lib/models";
import { uploadImage } from "@/lib/upload";
import { ErrorText, PageSpinner } from "@/components/ui";

const TAGS = ["Workshop", "Hackathon", "Seminar", "Talk", "Competition", "Cultural", "General"];
const FIELD_TYPES: FieldType[] = ["text", "email", "phone", "dropdown", "multiline"];

const toLocalInput = (d: Date | null) => {
  if (!d) return "";
  const local = new Date(d.getTime() - d.getTimezoneOffset() * 60_000);
  return local.toISOString().slice(0, 16);
};

const DEFAULT_FIELDS: RegistrationField[] = [
  { label: "Full Name", hint: "", type: "text", options: [], required: true },
  { label: "Phone", hint: "", type: "phone", options: [], required: true },
];

/** Event Builder (coordinators + HOD). Pass `id` to edit an existing event. */
export default function EventBuilder({ id }: { id?: string }) {
  const { profile } = useAuth();
  const router = useRouter();
  const [loading, setLoading] = useState(!!id);
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [venue, setVenue] = useState("");
  const [tag, setTag] = useState(TAGS[0]);
  const [club, setClub] = useState("");
  const [start, setStart] = useState("");
  const [end, setEnd] = useState("");
  const [deadline, setDeadline] = useState("");
  const [capacity, setCapacity] = useState("50");
  const [fields, setFields] = useState<RegistrationField[]>(DEFAULT_FIELDS);
  const [targetYears, setTargetYears] = useState<string[]>([]);
  const [fullDayEvent, setFullDayEvent] = useState(false);
  const [banner, setBanner] = useState<File | null>(null);
  const [bannerUrl, setBannerUrl] = useState<string | null>(null);
  const [registered, setRegistered] = useState(0);
  const [error, setError] = useState("");
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (!id) return;
    getDoc(doc(db, "events", id))
      .then((snap) => {
        if (!snap.exists()) throw new Error("Event not found.");
        const e = toEvent(snap.id, snap.data());
        setTitle(e.title);
        setDescription(e.description);
        setVenue(e.venue);
        setTag(TAGS.includes(e.tag) ? e.tag : "General");
        setClub(e.club ?? "");
        setStart(toLocalInput(e.eventDate));
        setEnd(toLocalInput(e.endDate));
        setDeadline(toLocalInput(e.registrationDeadline));
        setCapacity(String(e.maxCapacity));
        setFields(e.formFields);
        setTargetYears(e.targetYears);
        setFullDayEvent(e.sessions.length > 1);
        setBannerUrl(e.bannerUrl);
        setRegistered(e.currentRegistrations);
      })
      .catch((err) => setError(friendlyError(err)))
      .finally(() => setLoading(false));
  }, [id]);

  if (!profile || loading) return <PageSpinner />;

  const updateField = (i: number, patch: Partial<RegistrationField>) =>
    setFields((fs) => fs.map((f, idx) => (idx === i ? { ...f, ...patch } : f)));

  const save = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    const startDate = start ? new Date(start) : null;
    const endDate = end ? new Date(end) : null;
    const deadlineDate = deadline ? new Date(deadline) : startDate;
    const maxCapacity = Number.parseInt(capacity, 10);

    if (!title.trim() || !description.trim() || !venue.trim()) return setError("Title, description and venue are required.");
    if (!startDate) return setError("Pick the event start date and time.");
    if (endDate && endDate <= startDate) return setError("The end time must be after the start time.");
    if (deadlineDate && deadlineDate > startDate) return setError("Registration must close before the event starts.");
    if (!Number.isInteger(maxCapacity) || maxCapacity < 1) return setError("Capacity must be at least 1.");
    if (maxCapacity < registered) return setError(`${registered} students are already registered.`);
    if (fields.some((f) => !f.label.trim())) return setError("Every registration question needs a label.");
    if (fields.some((f) => f.type === "dropdown" && f.options.length === 0)) return setError("Dropdown questions need at least one option.");

    setSaving(true);
    try {
      const url = banner ? await uploadImage(banner, "event_banners") : bannerUrl;
      const resolvedClub = profile.role === "coordinator" ? profile.club : club || null;

      if (id) {
        // Edits never touch ownership, the live registration counter or the
        // review status — a coordinator can't self-approve by editing.
        await updateDoc(doc(db, "events", id), {
          title: title.trim(),
          description: description.trim(),
          venue: venue.trim(),
          tag,
          club: resolvedClub,
          eventDate: Timestamp.fromDate(startDate),
          endDate: endDate ? Timestamp.fromDate(endDate) : null,
          registrationDeadline: Timestamp.fromDate(deadlineDate ?? startDate),
          maxCapacity,
          customFormSchema: { fields },
          bannerUrl: url,
          targetYears,
          sessions: fullDayEvent ? ["morning", "afternoon"] : ["full"],
        });
        router.push(`/events/${id}`);
      } else {
        // Goes through the backend so a coordinator's event notifies the
        // HOD for approval in the same request (an HOD's own event is
        // auto-approved).
        const result = await callBackend<{ id: string; status: string }>("messaging/events", {
          title: title.trim(),
          description: description.trim(),
          venue: venue.trim(),
          tag,
          club: resolvedClub,
          eventDate: startDate.toISOString(),
          endDate: endDate ? endDate.toISOString() : null,
          registrationDeadline: (deadlineDate ?? startDate).toISOString(),
          maxCapacity,
          formFields: fields,
          bannerUrl: url,
          targetYears,
          fullDayEvent,
        });
        router.push(result.status === "pending" ? "/admin/events" : `/events/${result.id}`);
      }
    } catch (err) {
      setError(friendlyError(err));
      setSaving(false);
    }
  };

  return (
    <form onSubmit={save} className="flex flex-col gap-6 p-5">
      <h2 className="text-2xl font-extrabold text-text-primary">{id ? "Edit event" : "Create event"}</h2>

      <section className="card flex flex-col gap-4 p-4">
        <h3 className="font-bold text-text-primary">Basic info</h3>
        <div>
          <label htmlFor="ev-title" className="label">Event title</label>
          <input id="ev-title" className="input" maxLength={120} value={title} onChange={(e) => setTitle(e.target.value)} required />
        </div>
        <div>
          <label htmlFor="ev-desc" className="label">Description</label>
          <textarea id="ev-desc" className="input" rows={5} maxLength={3000} value={description} onChange={(e) => setDescription(e.target.value)} required />
        </div>
        <div>
          <label htmlFor="ev-venue" className="label">Venue</label>
          <input id="ev-venue" className="input" value={venue} onChange={(e) => setVenue(e.target.value)} required />
        </div>
        <div className="grid gap-4 sm:grid-cols-2">
          <div>
            <label htmlFor="ev-tag" className="label">Category</label>
            <select id="ev-tag" className="input" value={tag} onChange={(e) => setTag(e.target.value)}>
              {TAGS.map((t) => <option key={t}>{t}</option>)}
            </select>
          </div>
          {profile.role === "hod" ? (
            <div>
              <label htmlFor="ev-club" className="label">Club (optional)</label>
              <select id="ev-club" className="input" value={club} onChange={(e) => setClub(e.target.value)}>
                <option value="">Department (no club)</option>
                {CLUBS.map((c) => <option key={c}>{c}</option>)}
              </select>
            </div>
          ) : (
            <p className="self-end text-sm text-text-secondary">Organised by {profile.club ?? "your club"}</p>
          )}
        </div>
      </section>

      <section className="card grid gap-4 p-4 sm:grid-cols-2">
        <h3 className="font-bold text-text-primary sm:col-span-2">Schedule &amp; capacity</h3>
        <div>
          <label htmlFor="ev-start" className="label">Starts</label>
          <input id="ev-start" type="datetime-local" className="input" value={start} onChange={(e) => setStart(e.target.value)} required />
        </div>
        <div>
          <label htmlFor="ev-end" className="label">Ends (optional)</label>
          <input id="ev-end" type="datetime-local" className="input" value={end} onChange={(e) => setEnd(e.target.value)} />
        </div>
        <div>
          <label htmlFor="ev-deadline" className="label">Registration closes (defaults to start)</label>
          <input id="ev-deadline" type="datetime-local" className="input" value={deadline} onChange={(e) => setDeadline(e.target.value)} />
        </div>
        <div>
          <label htmlFor="ev-cap" className="label">Seat capacity</label>
          <input id="ev-cap" type="number" min={Math.max(1, registered)} className="input" value={capacity} onChange={(e) => setCapacity(e.target.value)} required />
        </div>
      </section>

      <section className="card flex flex-col gap-3 p-4">
        <h3 className="font-bold text-text-primary">Who is this for?</h3>
        <p className="text-xs text-text-secondary">Leave everything unselected for an event open to all years.</p>
        <div className="flex flex-wrap gap-2">
          {([["1", "1st Year"], ["2", "2nd Year"], ["3", "3rd Year"], ["4", "Final Year"]] as const).map(([value, label]) => {
            const selected = targetYears.includes(value);
            return (
              <button
                key={value}
                type="button"
                onClick={() =>
                  setTargetYears((ys) => (selected ? ys.filter((y) => y !== value) : [...ys, value]))
                }
                className={`rounded-full px-4 py-1.5 text-sm font-medium transition ${
                  selected ? "bg-secondary text-white" : "bg-primary-container text-text-secondary"
                }`}
              >
                {label}
              </button>
            );
          })}
        </div>
      </section>

      <section className="card flex flex-col gap-3 p-4">
        <h3 className="font-bold text-text-primary">Attendance</h3>
        <label className="flex items-center gap-3 text-sm">
          <input
            type="checkbox"
            className="h-4 w-4 accent-secondary"
            checked={fullDayEvent}
            onChange={(e) => setFullDayEvent(e.target.checked)}
          />
          <span>
            Full-day event
            <span className="block text-xs text-text-secondary">Generates separate morning and afternoon QR attendance sessions.</span>
          </span>
        </label>
      </section>

      <section className="card flex flex-col gap-3 p-4">
        <h3 className="font-bold text-text-primary">Banner (optional)</h3>
        {(banner || bannerUrl) && (
          // eslint-disable-next-line @next/next/no-img-element
          <img
            src={banner ? URL.createObjectURL(banner) : bannerUrl!}
            alt="Banner preview"
            className="h-80 w-full rounded-lg bg-primary-container object-contain"
          />
        )}
        <input type="file" accept="image/*" aria-label="Banner image — any size works, portrait posters are fine" onChange={(e) => setBanner(e.target.files?.[0] ?? null)} />
      </section>

      <section className="card flex flex-col gap-3 p-4">
        <h3 className="font-bold text-text-primary">Registration form</h3>
        <p className="text-xs text-text-secondary">Questions students answer when they register.</p>
        {fields.map((f, i) => (
          <div key={i} className="flex flex-col gap-2 rounded-lg border border-border p-3">
            <div className="flex gap-2">
              <input aria-label={`Question ${i + 1}`} className="input" placeholder="Question" value={f.label} onChange={(e) => updateField(i, { label: e.target.value })} />
              <button type="button" aria-label="Remove question" onClick={() => setFields((fs) => fs.filter((_, idx) => idx !== i))} className="text-text-tertiary hover:text-error">
                <Trash2 size={18} />
              </button>
            </div>
            <div className="flex flex-wrap items-center gap-3">
              <select aria-label="Answer type" className="input w-auto" value={f.type} onChange={(e) => updateField(i, { type: e.target.value as FieldType })}>
                {FIELD_TYPES.map((t) => <option key={t} value={t}>{t}</option>)}
              </select>
              <label className="flex items-center gap-2 text-sm">
                <input type="checkbox" className="h-4 w-4 accent-secondary" checked={f.required} onChange={(e) => updateField(i, { required: e.target.checked })} />
                Required
              </label>
            </div>
            {f.type === "dropdown" && (
              <input
                aria-label="Options"
                className="input"
                placeholder="Options, comma separated"
                value={f.options.join(", ")}
                onChange={(e) => updateField(i, { options: e.target.value.split(",").map((s) => s.trim()).filter(Boolean) })}
              />
            )}
          </div>
        ))}
        <button
          type="button"
          className="btn-outline self-start"
          onClick={() => setFields((fs) => [...fs, { label: "", hint: "", type: "text", options: [], required: false }])}
        >
          <Plus size={16} aria-hidden /> Add question
        </button>
      </section>

      <ErrorText message={error} />
      <button type="submit" className="btn-primary w-full py-3" disabled={saving}>
        {saving ? "Saving…" : id ? "Save changes" : "Publish event"}
      </button>
    </form>
  );
}
