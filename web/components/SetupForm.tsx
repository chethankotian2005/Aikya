"use client";

import { useEffect, useState } from "react";
import Image from "next/image";
import { callBackend } from "@/lib/api";
import { logout, useAuth } from "@/lib/auth-context";
import { friendlyError } from "@/lib/errors";
import { detectYear } from "@/lib/models";
import AvatarPicker from "@/components/AvatarPicker";
import { ErrorText, PageSpinner } from "@/components/ui";

const STEPS = ["Identity", "Academic info", "Socials", "Avatar"];

export default function SetupForm() {
  const { profile, user } = useAuth();
  const [step, setStep] = useState(0);
  const [fullName, setFullName] = useState("");
  const [phone, setPhone] = useState("");
  const [flag, setFlag] = useState(false);
  const [socials, setSocials] = useState({ githubUrl: "", linkedinUrl: "", instagramHandle: "", personalWebsite: "" });
  const [avatarId, setAvatarId] = useState<number | null>(null);
  const [error, setError] = useState("");
  const [saving, setSaving] = useState(false);
  const [prefilled, setPrefilled] = useState(false);

  useEffect(() => {
    if (!profile || prefilled) return;
    setFullName(profile.fullName);
    setPhone(profile.phone ?? "");
    setAvatarId(profile.avatarId ?? 1);
    setPrefilled(true);
  }, [profile, prefilled]);

  if (!profile || !user) return <PageSpinner />;

  const next = () => {
    setError("");
    if (step === 0) {
      if (!fullName.trim()) return setError("Please enter your full name.");
      if (!/^\+?\d{10,13}$/.test(phone.replace(/[\s-]/g, ""))) return setError("Please enter a valid phone number.");
    }
    setStep((s) => s + 1);
  };

  const complete = async () => {
    setError("");
    setSaving(true);
    try {
      const clean = (v: string) => v.trim() || null;
      await callBackend(
        "profile",
        {
          fullName: fullName.trim(),
          usn: profile.usn,
          phone: phone.trim(),
          githubUrl: clean(socials.githubUrl),
          linkedinUrl: clean(socials.linkedinUrl),
          instagramHandle: clean(socials.instagramHandle),
          personalWebsite: clean(socials.personalWebsite),
          avatarId,
          flagForHodReview: flag,
        },
        "PUT",
      );
      window.location.href = "/";
    } catch (err) {
      setError(friendlyError(err));
      setSaving(false);
    }
  };

  return (
    <div className="flex min-h-screen items-start justify-center bg-primary-surface px-4 py-10">
      <div className="card w-full max-w-lg p-8">
        <div className="mb-6 flex items-center justify-between">
          <Image src="/aikya_logo_cropped.png" alt="Aikya logo" width={64} height={64} className="object-contain" />
          <button type="button" onClick={logout} className="text-sm font-medium text-text-secondary hover:text-error">
            Log out
          </button>
        </div>
        <h1 className="text-2xl font-bold text-text-primary">Complete your profile</h1>
        <p className="mt-1 text-sm text-text-secondary">
          Step {step + 1} of {STEPS.length} · {STEPS[step]}
        </p>
        <div className="mt-4 mb-6 flex gap-1.5" aria-hidden>
          {STEPS.map((s, i) => (
            <div key={s} className={`h-1.5 flex-1 rounded-full ${i <= step ? "bg-secondary" : "bg-primary-container"}`} />
          ))}
        </div>

        {step === 0 && (
          <div className="space-y-4">
            <div>
              <label htmlFor="setup-name" className="label">Full Name</label>
              <input id="setup-name" className="input" value={fullName} onChange={(e) => setFullName(e.target.value)} />
            </div>
            <div>
              <label htmlFor="setup-usn" className="label">USN (linked to your account)</label>
              <input id="setup-usn" className="input" value={profile.usn} readOnly />
            </div>
            <div>
              <label htmlFor="setup-phone" className="label">Phone Number</label>
              <input id="setup-phone" type="tel" className="input" value={phone} onChange={(e) => setPhone(e.target.value)} placeholder="+91 98765 43210" />
            </div>
          </div>
        )}

        {step === 1 && (
          <div className="rounded-lg border border-border bg-primary-surface p-5">
            <p className="text-lg font-semibold text-text-primary">
              We&apos;ve detected you as: {detectYear(profile.usn)}, AI &amp; ML
            </p>
            <p className="mt-1 text-sm text-text-secondary">The HOD office confirms your batch from the official batch table.</p>
            <label className="mt-4 flex items-center gap-3 text-sm text-text-primary">
              <input type="checkbox" className="h-4 w-4 accent-secondary" checked={flag} onChange={(e) => setFlag(e.target.checked)} />
              This looks wrong — flag for HOD review
            </label>
          </div>
        )}

        {step === 2 && (
          <div className="space-y-4">
            {(
              [
                ["githubUrl", "GitHub URL"],
                ["linkedinUrl", "LinkedIn URL"],
                ["instagramHandle", "Instagram handle"],
                ["personalWebsite", "Personal website"],
              ] as const
            ).map(([key, label]) => (
              <div key={key}>
                <label htmlFor={`setup-${key}`} className="label">{label} (optional)</label>
                <input
                  id={`setup-${key}`}
                  className="input"
                  value={socials[key]}
                  onChange={(e) => setSocials((s) => ({ ...s, [key]: e.target.value }))}
                />
              </div>
            ))}
          </div>
        )}

        {step === 3 && (
          <div className="flex flex-col items-center gap-4">
            <p className="text-sm text-text-secondary">Pick an avatar to represent you.</p>
            <AvatarPicker value={avatarId} onChange={setAvatarId} />
          </div>
        )}

        <div className="mt-6"><ErrorText message={error} /></div>

        <div className="mt-6 flex items-center gap-3">
          {step > 0 && (
            <button type="button" className="btn-outline" onClick={() => setStep((s) => s - 1)} disabled={saving}>
              Back
            </button>
          )}
          <div className="flex-1" />
          {step < STEPS.length - 1 ? (
            <button type="button" className="btn-primary" onClick={next}>
              Continue
            </button>
          ) : (
            <button type="button" className="btn-primary" onClick={complete} disabled={saving}>
              {saving ? "Saving…" : "Complete setup"}
            </button>
          )}
        </div>
      </div>
    </div>
  );
}
