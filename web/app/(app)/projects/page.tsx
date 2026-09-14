"use client";

import { useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { collection, getDocs, limit, orderBy, query, where } from "firebase/firestore";
import { ChevronRight, FolderOpen, Plus, Search, User } from "lucide-react";
import { db } from "@/lib/firebase/firebase";
import { useAuth } from "@/lib/auth-context";
import { friendlyError } from "@/lib/errors";
import { useLiveQuery } from "@/lib/hooks";
import { toProfile, toProject, type UserProfile } from "@/lib/models";
import { Avatar, EmptyState, Fab, PageHeader, PageSpinner, TagChip } from "@/components/ui";
import ProjectCard from "@/components/ProjectCard";

function Directory() {
  const [students, setStudents] = useState<UserProfile[] | null>(null);
  const [error, setError] = useState("");
  const [search, setSearch] = useState("");

  useEffect(() => {
    getDocs(query(collection(db, "users"), where("role", "==", "student")))
      .then((snap) =>
        setStudents(snap.docs.map((d) => toProfile(d.id, d.data())).sort((a, b) => a.fullName.localeCompare(b.fullName))),
      )
      .catch((err) => setError(friendlyError(err)));
  }, []);

  if (error) return <EmptyState icon={User} message={error} />;
  if (!students) return <PageSpinner />;

  const q = search.trim().toLowerCase();
  const filtered = q
    ? students.filter((s) => s.fullName.toLowerCase().includes(q) || s.skills.some((sk) => sk.toLowerCase().includes(q)))
    : students;

  return (
    <div className="flex flex-col">
      <div className="px-5 py-3">
        <div className="relative">
          <Search size={18} className="pointer-events-none absolute top-1/2 left-3 -translate-y-1/2 text-text-tertiary" aria-hidden />
          <input type="search" aria-label="Search students" className="input pl-10" placeholder="Search by name or skills..." value={search} onChange={(e) => setSearch(e.target.value)} />
        </div>
      </div>
      <div className="flex flex-col gap-3 px-5 pb-6">
        {filtered.length === 0 ? (
          <EmptyState icon={User} message="No students found." />
        ) : (
          filtered.map((s) => (
            <Link key={s.uid} href={`/directory/${s.uid}`} className="card flex items-center gap-4 p-4 transition hover:border-accent/50">
              <Avatar name={s.fullName} url={s.profilePictureUrl} avatarId={s.avatarId} size={48} />
              <div className="min-w-0 flex-1">
                <h4 className="truncate text-[15px] font-bold text-text-primary">{s.fullName}</h4>
                <p className="mt-0.5 text-xs text-text-secondary">
                  {s.yearOfStudy ? `${s.yearOfStudy} Year` : "AI & ML"}
                  {s.batch ? ` · ${s.batch}` : ""}
                </p>
                {s.skills.length > 0 && (
                  <div className="mt-2 flex flex-wrap gap-1.5">
                    {s.skills.slice(0, 3).map((sk) => (
                      <TagChip key={sk} label={sk} tone="muted" />
                    ))}
                  </div>
                )}
              </div>
              <ChevronRight size={20} className="shrink-0 text-text-tertiary" aria-hidden />
            </Link>
          ))
        )}
      </div>
    </div>
  );
}

export default function ProjectsPage() {
  const { profile } = useAuth();
  const [tab, setTab] = useState<"showcase" | "directory">("showcase");
  const [tag, setTag] = useState("All");
  const projects = useLiveQuery(
    () => query(collection(db, "projects"), orderBy("createdAt", "desc"), limit(100)),
    toProject,
    [],
  );

  const tags = useMemo(() => [...new Set(projects.data.flatMap((p) => p.techStack))].sort(), [projects.data]);
  const filtered = tag === "All" ? projects.data : projects.data.filter((p) => p.techStack.includes(tag));

  return (
    <div className="flex flex-col">
      <PageHeader title="Projects" />

      <div className="px-5 pt-4 pb-2">
        <div role="tablist" className="flex rounded-full border border-border bg-surface-elevated p-1 shadow-sm">
          {(["showcase", "directory"] as const).map((t) => (
            <button
              key={t}
              role="tab"
              aria-selected={tab === t}
              onClick={() => setTab(t)}
              className={`flex-1 rounded-full py-2 text-sm font-semibold capitalize transition-all ${
                tab === t ? "bg-secondary text-white shadow-sm" : "text-text-secondary hover:text-text-primary"
              }`}
            >
              {t}
            </button>
          ))}
        </div>
      </div>

      {tab === "directory" ? (
        <Directory />
      ) : (
        <>
          {tags.length > 0 && (
            <div className="no-scrollbar w-full overflow-x-auto py-3">
              <div className="flex min-w-max gap-2 px-5">
                {["All", ...tags].map((t) => (
                  <button
                    key={t}
                    onClick={() => setTag(t)}
                    aria-pressed={tag === t}
                    className={`rounded-full border px-4 py-2 text-[13px] transition-colors ${
                      tag === t ? "border-secondary bg-secondary font-semibold text-white" : "border-border bg-surface-elevated font-medium text-text-secondary hover:bg-primary-container"
                    }`}
                  >
                    {t}
                  </button>
                ))}
              </div>
            </div>
          )}
          <div className="px-5 pb-10">
            {projects.loading ? (
              <PageSpinner />
            ) : filtered.length === 0 ? (
              <EmptyState
                icon={FolderOpen}
                message={projects.error || (projects.data.length === 0 ? "No projects yet. Students can submit theirs here." : `No projects use "${tag}".`)}
              />
            ) : (
              <div className="columns-2 gap-4">
                {filtered.map((p) => (
                  <ProjectCard key={p.id} project={p} />
                ))}
              </div>
            )}
          </div>
          {profile?.role === "student" && <Fab href="/projects/new" icon={Plus} label="Submit Project" />}
        </>
      )}
    </div>
  );
}
