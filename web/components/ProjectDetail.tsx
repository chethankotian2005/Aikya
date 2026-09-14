"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { deleteDoc, doc, getDoc, updateDoc } from "firebase/firestore";
import { ChevronRight, ExternalLink, FolderX, Trash2 } from "lucide-react";
import { db } from "@/lib/firebase/firebase";
import { useAuth } from "@/lib/auth-context";
import { friendlyError } from "@/lib/errors";
import { useLiveDoc } from "@/lib/hooks";
import { toProfile, toProject, type UserProfile } from "@/lib/models";
import { Avatar, BannerImage, EmptyState, ErrorText, PageHeader, PageSpinner, TagChip } from "@/components/ui";

export default function ProjectDetail({ id }: { id: string }) {
  const { profile } = useAuth();
  const router = useRouter();
  const project = useLiveDoc(() => doc(db, "projects", id), toProject, [id]);
  const [members, setMembers] = useState<UserProfile[]>([]);
  const [error, setError] = useState("");

  const p = project.data;
  const memberIds = p ? [p.ownerUid, ...p.contributors.filter((c) => c !== p.ownerUid)].join(",") : "";

  useEffect(() => {
    if (!memberIds) return;
    Promise.all(memberIds.split(",").map((uid) => getDoc(doc(db, "users", uid))))
      .then((snaps) => setMembers(snaps.filter((s) => s.exists()).map((s) => toProfile(s.id, s.data()!))))
      .catch(() => {});
  }, [memberIds]);

  if (project.loading || !profile) return <PageSpinner />;
  if (!p) {
    return (
      <>
        <PageHeader title="Project" back />
        <EmptyState icon={FolderX} message={project.error || "This project was removed."} />
      </>
    );
  }

  const isOwner = p.ownerUid === profile.uid;
  const canDelete = isOwner || profile.role === "hod";

  const remove = async () => {
    if (!confirm(`Delete "${p.title}" for everyone?`)) return;
    try {
      await deleteDoc(doc(db, "projects", id));
      router.replace("/projects");
    } catch (err) {
      setError(friendlyError(err));
    }
  };

  return (
    <div className="flex flex-col">
      <PageHeader
        title="Project Details"
        back
        action={
          canDelete && (
            <button type="button" onClick={remove} aria-label="Delete project" className="text-text-tertiary hover:text-error">
              <Trash2 size={20} />
            </button>
          )
        }
      />
      <div className="flex flex-col gap-5 px-5 pt-3 pb-8">
        <div className="no-scrollbar flex snap-x gap-3 overflow-x-auto">
          {(p.images.length ? p.images : [null]).map((url, i) => (
            <BannerImage key={url ?? i} url={url} alt={p.title} className="aspect-video w-full shrink-0 snap-center rounded-lg" />
          ))}
        </div>

        {p.lookingForTeammate && <TagChip label="Looking for teammates" />}
        <h2 className="text-2xl leading-tight font-bold text-text-primary">{p.title}</h2>
        <div className="flex flex-wrap gap-2">
          {p.techStack.map((t) => (
            <TagChip key={t} label={t} tone="secondary" />
          ))}
        </div>

        <section>
          <h3 className="mb-2 font-bold text-text-primary">Description</h3>
          <p className="text-sm leading-relaxed whitespace-pre-line text-text-secondary">{p.description || "No description provided."}</p>
        </section>

        {p.repoUrl && (
          <a href={p.repoUrl} target="_blank" rel="noopener noreferrer" className="btn-outline self-start">
            <ExternalLink size={16} aria-hidden /> Open repository / demo
          </a>
        )}

        {isOwner && (
          <label className="flex items-center gap-3 text-sm font-medium text-text-primary">
            <input
              type="checkbox"
              className="h-4 w-4 accent-secondary"
              checked={p.lookingForTeammate}
              onChange={(e) =>
                updateDoc(doc(db, "projects", id), { lookingForTeammate: e.target.checked }).catch((err) => setError(friendlyError(err)))
              }
            />
            Looking for teammates
          </label>
        )}
        <ErrorText message={error} />

        <section>
          <h3 className="mb-3 font-bold text-text-primary">Team</h3>
          <div className="flex flex-col gap-2">
            {members.map((m) => (
              <Link key={m.uid} href={`/directory/${m.uid}`} className="card flex items-center gap-3 p-3 transition hover:border-accent/50">
                <Avatar name={m.fullName} url={m.profilePictureUrl} avatarId={m.avatarId} size={40} />
                <div className="flex-1">
                  <p className="text-sm font-semibold text-text-primary">{m.fullName}</p>
                  <p className="text-xs text-text-tertiary">{m.uid === p.ownerUid ? "Owner" : "Contributor"}</p>
                </div>
                <ChevronRight size={18} className="text-text-tertiary" aria-hidden />
              </Link>
            ))}
          </div>
        </section>
      </div>
    </div>
  );
}
