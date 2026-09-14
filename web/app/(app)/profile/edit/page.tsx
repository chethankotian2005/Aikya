"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { callBackend } from "@/lib/api";
import { useAuth } from "@/lib/auth-context";
import { friendlyError } from "@/lib/errors";
import { ROLE_LABELS } from "@/lib/models";
import AvatarPicker from "@/components/AvatarPicker";
import { ErrorText, PageHeader, PageSpinner } from "@/components/ui";

const SOCIALS = [
  ["githubUrl", "GitHub URL"],
  ["linkedinUrl", "LinkedIn URL"],
  ["twitterHandle", "X / Twitter handle"],
  ["discordHandle", "Discord handle"],
  ["instagramHandle", "Instagram handle"],
  ["personalWebsite", "Personal website"],
] as const;

const PRIVACY = [
  ["publicBio", "Public bio"],
  ["publicGithub", "Public GitHub"],
  ["publicLinkedin", "Public LinkedIn"],
  ["publicInstagram", "Public Instagram"],
  ["publicTwitter", "Public X / Twitter"],
  ["publicPersonalWebsite", "Public website"],
] as const;

const NOTIFICATIONS = [
  ["eventsEnabled", "Event & attendance updates"],
  ["updatesEnabled", "Faculty updates"],
  ["memoriesEnabled", "Memory Wall approvals"],
] as const;

type SocialKey = (typeof SOCIALS)[number][0];

export default function EditProfilePage() {
  const { profile, user } = useAuth();
  const router = useRouter();
  const [loaded, setLoaded] = useState(false);
  const [phone, setPhone] = useState("");
  const [bio, setBio] = useState("");
  const [skills, setSkills] = useState("");
  const [socials, setSocials] = useState<Record<SocialKey, string>>({
    githubUrl: "", linkedinUrl: "", twitterHandle: "", discordHandle: "", instagramHandle: "", personalWebsite: "",
  });
  const [privacy, setPrivacy] = useState<Record<string, boolean>>({});
  const [notifications, setNotifications] = useState<Record<string, boolean>>({});
  const [flag, setFlag] = useState(false);
  const [avatarId, setAvatarId] = useState<number | null>(null);
  const [error, setError] = useState("");
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (!profile || loaded) return;
    setPhone(profile.phone ?? "");
    setBio(profile.bio ?? "");
    setSkills(profile.skills.join(", "));
    setSocials(Object.fromEntries(SOCIALS.map(([k]) => [k, profile[k] ?? ""])) as Record<SocialKey, string>);
    setPrivacy(Object.fromEntries(PRIVACY.map(([k]) => [k, profile.privacySettings[k] !== false])));
    setNotifications(Object.fromEntries(NOTIFICATIONS.map(([k]) => [k, profile.notificationSettings[k] !== false])));
    setAvatarId(profile.avatarId ?? 1);
    setLoaded(true);
  }, [profile, loaded]);

  if (!profile || !user) return <PageSpinner />;
  const isStudent = profile.role === "student";

  const save = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setSaving(true);
    try {
      await callBackend(
        "profile",
        {
          fullName: profile.fullName,
          ...(profile.usn ? { usn: profile.usn } : {}),
          phone: phone.trim() || null,
          bio: bio.trim() || null,
          skills: skills.split(",").map((s) => s.trim()).filter(Boolean),
          ...Object.fromEntries(SOCIALS.map(([k]) => [k, socials[k].trim() || null])),
          avatarId,
          flagForHodReview: flag,
          privacySettings: privacy,
          notificationSettings: notifications,
        },
        "PUT",
      );
      router.push("/profile");
    } catch (err) {
      setError(friendlyError(err));
      setSaving(false);
    }
  };

  const toggle = (label: string, checked: boolean, onChange: (v: boolean) => void) => (
    <label key={label} className="flex items-center justify-between py-2.5 text-sm text-text-primary">
      {label}
      <input type="checkbox" className="h-4 w-4 accent-secondary" checked={checked} onChange={(e) => onChange(e.target.checked)} />
    </label>
  );

  return (
    <div className="flex flex-col">
      <PageHeader title="Edit Profile" back />
      <form onSubmit={save} className="flex flex-col gap-6 px-5 pt-4 pb-10">
        <div className="flex flex-col items-center gap-3">
          <p className="text-sm text-text-secondary">Choose your avatar</p>
          <AvatarPicker value={avatarId} onChange={setAvatarId} />
        </div>

        <section className="card p-4">
          <h2 className="mb-3 font-bold text-text-primary">Identity</h2>
          <p className="text-sm text-text-secondary">{profile.fullName}</p>
          <p className="text-sm text-text-secondary">
            {isStudent ? `USN ${profile.usn} · ${profile.yearOfStudy ?? "-"} Year · ${profile.batch ?? "Pending review"}` : [ROLE_LABELS[profile.role], profile.club].filter(Boolean).join(" · ")}
          </p>
          {isStudent && (
            <label className="mt-3 flex items-center gap-3 text-sm text-text-primary">
              <input type="checkbox" className="h-4 w-4 accent-secondary" checked={flag} onChange={(e) => setFlag(e.target.checked)} />
              Name, USN or batch wrong? Flag for HOD review
            </label>
          )}
        </section>

        <section className="card flex flex-col gap-4 p-4">
          <h2 className="font-bold text-text-primary">Contact &amp; bio</h2>
          <div>
            <label htmlFor="e-phone" className="label">Phone</label>
            <input id="e-phone" type="tel" className="input" value={phone} onChange={(e) => setPhone(e.target.value)} />
          </div>
          <div>
            <label htmlFor="e-bio" className="label">Bio</label>
            <textarea id="e-bio" className="input" rows={3} maxLength={150} value={bio} onChange={(e) => setBio(e.target.value)} />
          </div>
          <div>
            <label htmlFor="e-skills" className="label">Skills (comma separated)</label>
            <input id="e-skills" className="input" value={skills} onChange={(e) => setSkills(e.target.value)} placeholder="Python, PyTorch, Flutter" />
          </div>
        </section>

        <section className="card flex flex-col gap-4 p-4">
          <h2 className="font-bold text-text-primary">Social links</h2>
          {SOCIALS.map(([key, label]) => (
            <div key={key}>
              <label htmlFor={`e-${key}`} className="label">{label}</label>
              <input id={`e-${key}`} className="input" value={socials[key]} onChange={(e) => setSocials((s) => ({ ...s, [key]: e.target.value }))} />
            </div>
          ))}
        </section>

        <section className="card divide-y divide-border px-4 py-2">
          <h2 className="py-2 font-bold text-text-primary">Privacy</h2>
          {PRIVACY.map(([key, label]) => toggle(label, privacy[key] ?? true, (v) => setPrivacy((p) => ({ ...p, [key]: v }))))}
        </section>

        <section className="card divide-y divide-border px-4 py-2">
          <h2 className="py-2 font-bold text-text-primary">Notifications</h2>
          {NOTIFICATIONS.map(([key, label]) => toggle(label, notifications[key] ?? true, (v) => setNotifications((n) => ({ ...n, [key]: v }))))}
        </section>

        <ErrorText message={error} />
        <button type="submit" className="btn-primary w-full py-3" disabled={saving}>
          {saving ? "Saving…" : "Save profile"}
        </button>
      </form>
    </div>
  );
}
