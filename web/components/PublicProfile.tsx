"use client";

import { collection, doc, query, where } from "firebase/firestore";
import { AtSign, Briefcase as Linkedin, Camera as Instagram, Code2, Globe, UserX } from "lucide-react";
import { db } from "@/lib/firebase/firebase";
import { useLiveDoc, useLiveQuery } from "@/lib/hooks";
import { ROLE_LABELS, toProfile, toProject } from "@/lib/models";
import { Avatar, EmptyState, PageHeader, PageSpinner, TagChip } from "@/components/ui";
import ProjectCard from "@/components/ProjectCard";

export default function PublicProfile({ uid }: { uid: string }) {
  const user = useLiveDoc(() => doc(db, "users", uid), toProfile, [uid]);
  const projects = useLiveQuery(() => query(collection(db, "projects"), where("ownerUid", "==", uid)), toProject, [uid]);

  if (user.loading) return <PageSpinner />;
  const u = user.data;
  if (!u) {
    return (
      <>
        <PageHeader title="Profile" back />
        <EmptyState icon={UserX} message={user.error || "This profile could not be loaded."} />
      </>
    );
  }

  const show = (key: string) => u.privacySettings[key] !== false;
  const links = [
    show("publicGithub") && u.githubUrl && { icon: Code2, label: "GitHub", href: u.githubUrl },
    show("publicLinkedin") && u.linkedinUrl && { icon: Linkedin, label: "LinkedIn", href: u.linkedinUrl },
    show("publicTwitter") && u.twitterHandle && { icon: AtSign, label: "X", href: `https://x.com/${u.twitterHandle.replace("@", "")}` },
    show("publicInstagram") && u.instagramHandle && { icon: Instagram, label: "Instagram", href: `https://instagram.com/${u.instagramHandle.replace("@", "")}` },
    show("publicPersonalWebsite") && u.personalWebsite && { icon: Globe, label: "Website", href: u.personalWebsite },
  ].filter(Boolean) as { icon: typeof Globe; label: string; href: string }[];

  const subtitle =
    u.role === "student"
      ? `${u.yearOfStudy ? `${u.yearOfStudy} Year` : "AI & ML"}${u.batch ? ` · ${u.batch}` : ""}`
      : [u.designation ?? ROLE_LABELS[u.role], u.club].filter(Boolean).join(" · ");

  return (
    <div className="flex flex-col">
      <PageHeader title={u.fullName} back />
      <div className="flex flex-col items-center gap-3 px-5 pt-6 text-center">
        <Avatar name={u.fullName} url={u.profilePictureUrl} size={100} />
        <h2 className="text-xl font-bold text-text-primary">{u.fullName}</h2>
        <p className="text-sm text-text-secondary">{subtitle}</p>
        {u.skills.length > 0 && (
          <div className="flex flex-wrap justify-center gap-2">
            {u.skills.map((s) => (
              <TagChip key={s} label={s} tone="secondary" />
            ))}
          </div>
        )}
      </div>

      {show("publicBio") && u.bio && (
        <section className="card mx-5 mt-6 p-4">
          <h3 className="text-sm font-bold text-text-primary">About</h3>
          <p className="mt-2 text-sm leading-relaxed text-text-secondary">{u.bio}</p>
        </section>
      )}

      {links.length > 0 && (
        <div className="mt-6 flex flex-wrap justify-center gap-2 px-5">
          {links.map((l) => (
            <a key={l.label} href={l.href} target="_blank" rel="noopener noreferrer" className="btn-outline">
              <l.icon size={16} aria-hidden /> {l.label}
            </a>
          ))}
        </div>
      )}

      {u.role === "student" && (
        <section className="px-5 pt-8 pb-6">
          <h3 className="mb-4 text-lg font-bold text-text-primary">Projects</h3>
          {projects.data.length === 0 ? (
            <p className="text-center text-sm text-text-tertiary">No projects yet.</p>
          ) : (
            <div className="columns-2 gap-4">
              {projects.data.map((p) => (
                <ProjectCard key={p.id} project={p} />
              ))}
            </div>
          )}
        </section>
      )}
    </div>
  );
}
