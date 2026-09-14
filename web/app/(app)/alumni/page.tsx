"use client";

import { useState } from "react";
import { collection } from "firebase/firestore";
import { BadgeCheck, Briefcase as Linkedin, GraduationCap, Handshake, MapPin, Search, X } from "lucide-react";
import { db } from "@/lib/firebase/firebase";
import { useLiveQuery } from "@/lib/hooks";
import { toAlumni, type AlumniProfile } from "@/lib/models";
import { Avatar, EmptyState, PageHeader, PageSpinner } from "@/components/ui";

/** Solid accent pill — deliberately high-contrast so mentors stand out. */
function MentorBadge() {
  return (
    <span className="inline-flex items-center gap-1 rounded-full bg-accent px-2.5 py-1 text-[11px] font-bold text-white">
      <Handshake size={13} aria-hidden /> Open to mentor
    </span>
  );
}

const roleLine = (a: AlumniProfile) =>
  a.jobTitle && a.currentCompany ? `${a.jobTitle} @ ${a.currentCompany}` : a.jobTitle || a.currentCompany;

export default function AlumniPage() {
  const alumni = useLiveQuery(() => collection(db, "alumniProfiles"), toAlumni, []);
  const [search, setSearch] = useState("");
  const [mentorsOnly, setMentorsOnly] = useState(false);
  const [selected, setSelected] = useState<AlumniProfile | null>(null);

  const q = search.trim().toLowerCase();
  const visible = alumni.data
    .filter((a) => !mentorsOnly || a.isOpenForMentorship)
    .filter((a) => !q || [a.fullName, a.currentCompany, a.jobTitle, a.location].some((v) => v.toLowerCase().includes(q)))
    .sort((a, b) => (b.graduationYear ?? 0) - (a.graduationYear ?? 0));

  return (
    <div className="flex flex-col">
      <PageHeader title="Alumni Network" />
      <div className="flex flex-col gap-3 px-5 py-4">
        <div className="relative">
          <Search size={18} className="pointer-events-none absolute top-1/2 left-3 -translate-y-1/2 text-text-tertiary" aria-hidden />
          <input type="search" aria-label="Search alumni" className="input pl-10" placeholder="Search by name, role, company or city..." value={search} onChange={(e) => setSearch(e.target.value)} />
        </div>
        <button
          type="button"
          aria-pressed={mentorsOnly}
          onClick={() => setMentorsOnly((v) => !v)}
          className={`flex items-center gap-2 self-start rounded-full border px-4 py-1.5 text-xs font-semibold transition ${
            mentorsOnly ? "border-accent bg-accent text-white" : "border-border bg-surface-elevated text-text-secondary"
          }`}
        >
          <Handshake size={14} aria-hidden /> Open to mentor
        </button>
      </div>

      <div className="flex flex-col gap-4 px-5 pb-8">
        {alumni.loading ? (
          <PageSpinner />
        ) : visible.length === 0 ? (
          <EmptyState icon={GraduationCap} message={alumni.error || (alumni.data.length === 0 ? "No alumni profiles yet." : "No alumni match your search.")} />
        ) : (
          visible.map((a) => (
            <button
              key={a.uid}
              type="button"
              onClick={() => setSelected(a)}
              className={`card flex items-start gap-4 p-4 text-left transition hover:border-accent/50 ${a.isOpenForMentorship ? "border-accent/50" : ""}`}
            >
              <Avatar name={a.fullName} size={52} />
              <div className="min-w-0 flex-1">
                <h3 className="flex items-center gap-1 truncate text-[16px] font-bold text-text-primary">
                  {a.fullName}
                  {a.verifiedByHod && <BadgeCheck size={16} className="shrink-0 text-accent" aria-label="Verified by HOD" />}
                </h3>
                {roleLine(a) && <p className="mt-0.5 truncate text-[13px] font-semibold text-text-secondary">{roleLine(a)}</p>}
                <p className="mt-1 text-[11px] text-text-tertiary">
                  {[a.graduationYear && `Batch of ${a.graduationYear}`, a.location].filter(Boolean).join(" · ")}
                </p>
                {a.isOpenForMentorship && (
                  <div className="mt-2">
                    <MentorBadge />
                  </div>
                )}
              </div>
            </button>
          ))
        )}
      </div>

      {selected && (
        <div className="fixed inset-0 z-[60] flex items-end justify-center bg-black/50 sm:items-center" onClick={() => setSelected(null)}>
          <div
            role="dialog"
            aria-modal="true"
            aria-label={selected.fullName}
            className="w-full max-w-lg rounded-t-2xl bg-surface-elevated p-6 sm:rounded-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-start gap-4">
              <Avatar name={selected.fullName} size={64} />
              <div className="flex-1">
                <h2 className="text-xl font-extrabold text-text-primary">{selected.fullName}</h2>
                {roleLine(selected) && <p className="text-sm text-text-secondary">{roleLine(selected)}</p>}
                {selected.graduationYear && <p className="text-xs text-text-tertiary">Batch of {selected.graduationYear}</p>}
              </div>
              <button type="button" aria-label="Close" onClick={() => setSelected(null)} className="text-text-tertiary hover:text-text-primary">
                <X size={20} />
              </button>
            </div>
            <div className="mt-4 flex flex-wrap gap-2">
              {selected.isOpenForMentorship && <MentorBadge />}
              {selected.location && (
                <span className="inline-flex items-center gap-1 rounded-full bg-primary-container px-2.5 py-1 text-[11px] text-text-secondary">
                  <MapPin size={12} aria-hidden /> {selected.location}
                </span>
              )}
            </div>
            {selected.bio && <p className="mt-4 text-sm leading-relaxed text-text-secondary">{selected.bio}</p>}
            {selected.linkedinUrl ? (
              <a href={selected.linkedinUrl} target="_blank" rel="noopener noreferrer" className="btn-primary mt-6 w-full">
                <Linkedin size={18} aria-hidden />
                {selected.isOpenForMentorship ? "Ask for mentorship on LinkedIn" : "Connect on LinkedIn"}
              </a>
            ) : (
              <p className="mt-6 text-center text-xs text-text-tertiary">No LinkedIn profile shared.</p>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
