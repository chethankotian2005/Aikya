import Link from "next/link";
import { UserPlus } from "lucide-react";
import type { ProjectItem } from "@/lib/models";
import { BannerImage, TagChip } from "@/components/ui";

export default function ProjectCard({ project }: { project: ProjectItem }) {
  return (
    <Link href={`/projects/${project.id}`} className="card mb-4 block break-inside-avoid overflow-hidden transition hover:border-accent/50">
      <div className="relative aspect-[4/3] w-full">
        <BannerImage url={project.images[0] ?? null} alt={project.title} className="h-full w-full" />
        {project.lookingForTeammate && (
          <span className="absolute top-2 right-2 flex items-center gap-1 rounded-full bg-accent px-2 py-1 text-[9px] font-bold tracking-wider text-white">
            <UserPlus size={10} aria-hidden /> TEAMMATE
          </span>
        )}
      </div>
      <div className="p-3">
        <h4 className="line-clamp-2 text-sm leading-snug font-bold text-text-primary">{project.title}</h4>
        {project.ownerName && <p className="mt-1 text-[11px] font-medium text-text-tertiary">by {project.ownerName}</p>}
        {project.techStack.length > 0 && (
          <div className="mt-2.5 flex flex-wrap gap-1.5">
            {project.techStack.slice(0, 4).map((t) => (
              <TagChip key={t} label={t} tone="secondary" />
            ))}
          </div>
        )}
      </div>
    </Link>
  );
}
