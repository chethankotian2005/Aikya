"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { ArrowLeft, Sparkles, type LucideIcon } from "lucide-react";
import type { ReactNode } from "react";
import { initials } from "@/lib/models";

export function PageHeader({ title, back, action }: { title: string; back?: boolean; action?: ReactNode }) {
  const router = useRouter();
  return (
    <header className="flex items-center gap-3 px-5 pt-5 pb-2">
      {back && (
        <button
          type="button"
          onClick={() => router.back()}
          aria-label="Go back"
          className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full border border-border bg-surface-elevated text-text-secondary transition hover:bg-primary-container"
        >
          <ArrowLeft size={20} />
        </button>
      )}
      <h1 className="flex-1 truncate text-xl font-bold tracking-tight text-text-primary">{title}</h1>
      {action}
    </header>
  );
}

/** Gradient "AI" pill required on every AI-generated surface (spec §3). */
export function AiBadge({ label = "AI" }: { label?: string }) {
  return (
    <span className="inline-flex items-center gap-1 rounded-full bg-ai-badge-gradient px-2 py-0.5 text-[10px] font-semibold tracking-wide text-white">
      <Sparkles size={10} aria-hidden /> {label}
    </span>
  );
}

const TONES = {
  accent: "bg-accent/12 text-accent",
  secondary: "bg-secondary/12 text-secondary",
  success: "bg-success/12 text-success",
  warning: "bg-warning/15 text-warning",
  error: "bg-error/12 text-error",
  muted: "bg-primary-container text-text-secondary",
} as const;

export function TagChip({ label, tone = "accent" }: { label: string; tone?: keyof typeof TONES }) {
  return (
    <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-[10px] font-semibold uppercase tracking-wide ${TONES[tone]}`}>
      {label}
    </span>
  );
}

export function EmptyState({ icon: Icon, message, action }: { icon: LucideIcon; message: string; action?: ReactNode }) {
  return (
    <div className="flex flex-col items-center justify-center gap-3 px-6 py-12 text-center text-text-tertiary">
      <Icon size={44} className="opacity-60" aria-hidden />
      <p className="max-w-sm text-sm text-text-secondary">{message}</p>
      {action}
    </div>
  );
}

export function Spinner({ className = "" }: { className?: string }) {
  return (
    <div
      role="status"
      aria-label="Loading"
      className={`h-6 w-6 animate-spin rounded-full border-2 border-accent border-t-transparent ${className}`}
    />
  );
}

export function PageSpinner() {
  return (
    <div className="flex justify-center py-16">
      <Spinner />
    </div>
  );
}

export function Avatar({ name, url, size = 44 }: { name: string; url?: string | null; size?: number }) {
  return (
    <div
      className="flex shrink-0 items-center justify-center overflow-hidden rounded-full bg-ai-badge-gradient font-bold text-white"
      style={{ width: size, height: size, fontSize: size * 0.36 }}
    >
      {url ? (
        // eslint-disable-next-line @next/next/no-img-element
        <img src={url} alt={name} className="h-full w-full object-cover" />
      ) : (
        initials(name)
      )}
    </div>
  );
}

export function ErrorText({ message }: { message: string }) {
  if (!message) return null;
  return (
    <p role="alert" className="text-sm font-medium text-error">
      {message}
    </p>
  );
}

export function Fab({ href, icon: Icon, label }: { href: string; icon: LucideIcon; label: string }) {
  return (
    <Link
      href={href}
      className="fixed right-5 bottom-24 z-40 flex items-center gap-2 rounded-full bg-secondary px-5 py-3.5 text-sm font-semibold text-white shadow-lg transition hover:bg-accent-hover"
    >
      <Icon size={20} strokeWidth={2.5} aria-hidden />
      {label}
    </Link>
  );
}

/** Image with a brand-gradient placeholder (event banners, project covers). */
export function BannerImage({ url, alt, className = "" }: { url: string | null; alt: string; className?: string }) {
  if (!url) return <div className={`bg-brand-gradient ${className}`} aria-hidden />;
  // eslint-disable-next-line @next/next/no-img-element
  return <img src={url} alt={alt} className={`object-cover ${className}`} />;
}
