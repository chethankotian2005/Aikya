"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { Calendar, FolderOpen, Home, User, Users } from "lucide-react";

const NAV_ITEMS = [
  { name: "Home", href: "/", icon: Home },
  { name: "Events", href: "/events", icon: Calendar },
  { name: "Projects", href: "/projects", icon: FolderOpen },
  { name: "Alumni", href: "/alumni", icon: Users },
  { name: "Profile", href: "/profile", icon: User },
];

export default function BottomNav() {
  const pathname = usePathname();

  return (
    <nav
      aria-label="Main"
      className="pb-safe fixed right-0 bottom-0 left-0 z-50 border-t border-border bg-surface-elevated"
    >
      <div className="mx-auto flex h-16 max-w-md items-center justify-around">
        {NAV_ITEMS.map(({ name, href, icon: Icon }) => {
          const isActive = pathname === href || (href !== "/" && pathname.startsWith(href));
          return (
            <Link
              key={name}
              href={href}
              aria-current={isActive ? "page" : undefined}
              className={`relative flex h-full w-full flex-col items-center justify-center gap-1 transition-colors ${
                isActive ? "text-accent" : "text-text-tertiary hover:text-text-secondary"
              }`}
            >
              {isActive && <span className="absolute top-0 h-0.5 w-8 rounded-full bg-accent" aria-hidden />}
              <Icon size={22} strokeWidth={isActive ? 2.5 : 2} aria-hidden />
              <span className={`text-[10px] ${isActive ? "font-semibold" : "font-medium"}`}>{name}</span>
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
