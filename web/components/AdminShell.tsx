"use client";

import { useState, type ReactNode } from "react";
import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  BarChart3, Calendar, FileText, Home, LayoutDashboard, LogOut, Menu,
  Settings, ShieldAlert, ShieldCheck, UserPlus, X,
} from "lucide-react";
import { logout } from "@/lib/auth-context";
import { ROLE_LABELS, type Role } from "@/lib/models";
import { TagChip } from "@/components/ui";

const NAV_ITEMS = [
  { name: "Dashboard", href: "/admin", icon: LayoutDashboard, hodOnly: false },
  { name: "Events", href: "/admin/events", icon: Calendar, hodOnly: false },
  { name: "Report Generator", href: "/admin/reports", icon: FileText, hodOnly: false },
  { name: "Analytics", href: "/admin/analytics", icon: BarChart3, hodOnly: false },
  { name: "Accreditation", href: "/admin/accreditation", icon: ShieldCheck, hodOnly: true },
  { name: "Moderation", href: "/admin/moderation", icon: ShieldAlert, hodOnly: true },
  { name: "Batch Config", href: "/admin/config", icon: Settings, hodOnly: true },
  { name: "Staff", href: "/admin/staff", icon: UserPlus, hodOnly: true },
];

export default function AdminShell({ role, name, children }: { role: Role; name: string; children: ReactNode }) {
  const [drawerOpen, setDrawerOpen] = useState(false);
  const pathname = usePathname();
  const items = NAV_ITEMS.filter((item) => !item.hodOnly || role === "hod");
  const current =
    [...items].sort((a, b) => b.href.length - a.href.length).find((item) => pathname.startsWith(item.href)) ?? items[0];

  return (
    <div className="relative flex min-h-screen flex-col bg-primary-surface">
      <header className="sticky top-0 z-20 flex h-16 items-center justify-between border-b border-border bg-surface-elevated px-5">
        <div className="flex items-center gap-4">
          <button
            type="button"
            onClick={() => setDrawerOpen(true)}
            aria-label="Open admin menu"
            className="text-text-primary transition hover:text-accent"
          >
            <Menu size={24} />
          </button>
          <h1 className="text-lg font-bold tracking-tight text-text-primary">{current.name}</h1>
        </div>
        <TagChip label={ROLE_LABELS[role]} />
      </header>

      {drawerOpen && (
        <div className="fixed inset-0 z-30 bg-black/50" onClick={() => setDrawerOpen(false)} aria-hidden />
      )}

      <aside
        aria-label="Admin navigation"
        className={`fixed inset-y-0 left-0 z-40 flex w-[280px] flex-col bg-surface-elevated shadow-2xl transition-transform duration-300 ${
          drawerOpen ? "translate-x-0" : "-translate-x-full"
        }`}
      >
        <div className="flex items-center justify-between border-b border-border p-5">
          <div className="flex items-center gap-3">
            <Image src="/aikya_logo_cropped.png" alt="" width={40} height={40} className="object-contain" />
            <div>
              <p className="text-lg font-extrabold tracking-tight text-text-primary">AIKYA</p>
              <p className="max-w-[160px] truncate text-xs text-text-tertiary">Admin Portal · {name}</p>
            </div>
          </div>
          <button
            type="button"
            onClick={() => setDrawerOpen(false)}
            aria-label="Close admin menu"
            className="text-text-tertiary hover:text-text-primary"
          >
            <X size={20} />
          </button>
        </div>

        <nav className="flex flex-1 flex-col gap-1 overflow-y-auto px-3 py-4">
          {items.map((item) => {
            const isActive = item === current;
            return (
              <Link
                key={item.href}
                href={item.href}
                onClick={() => setDrawerOpen(false)}
                aria-current={isActive ? "page" : undefined}
                className={`flex items-center gap-3 rounded-full px-4 py-2.5 text-sm transition-colors ${
                  isActive ? "bg-secondary font-semibold text-white" : "font-medium text-text-secondary hover:bg-primary-container"
                }`}
              >
                <item.icon size={20} aria-hidden />
                {item.name}
              </Link>
            );
          })}
        </nav>

        <div className="flex flex-col gap-1 border-t border-border p-3">
          <Link href="/" className="flex items-center gap-3 rounded-full px-4 py-2.5 text-sm font-medium text-text-secondary hover:bg-primary-container">
            <Home size={20} aria-hidden /> Back to app
          </Link>
          <button
            type="button"
            onClick={logout}
            className="flex items-center gap-3 rounded-full px-4 py-2.5 text-sm font-semibold text-error transition-colors hover:bg-error/10"
          >
            <LogOut size={20} aria-hidden /> Sign out
          </button>
        </div>
      </aside>

      <div className="mx-auto w-full max-w-5xl flex-1">{children}</div>
    </div>
  );
}
