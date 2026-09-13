"use client";

import { useState } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { 
  Menu, X, LayoutDashboard, Calendar, FileText, 
  ShieldCheck, ShieldAlert, CheckSquare, BarChart3, 
  Settings, LogOut 
} from "lucide-react";

const navItems = [
  { name: "Dashboard", href: "/admin", icon: LayoutDashboard },
  { name: "Events", href: "/admin/events", icon: Calendar },
  { name: "Report Generator", href: "/admin/reports", icon: FileText },
  { name: "Accreditation", href: "/admin/accreditation", icon: ShieldCheck },
  { name: "Moderation", href: "/admin/moderation", icon: ShieldAlert },
  { name: "Attendance", href: "/admin/attendance", icon: CheckSquare },
  { name: "Analytics", href: "/admin/analytics", icon: BarChart3 },
  { name: "Batch Config", href: "/admin/config", icon: Settings },
];

export default function AdminLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const [drawerOpen, setDrawerOpen] = useState(false);
  const pathname = usePathname();
  const router = useRouter();

  const currentNavItem = navItems.find(item => item.href === pathname) || navItems[0];

  return (
    <div className="flex flex-col min-h-screen bg-primary-surface relative">
      
      {/* ─── App Bar ─── */}
      <header className="h-16 px-5 border-b border-border bg-primary-surface flex items-center justify-between sticky top-0 z-20">
        <div className="flex items-center gap-4">
          <button 
            onClick={() => setDrawerOpen(true)}
            className="text-text-primary hover:text-accent transition"
          >
            <Menu size={24} />
          </button>
          <h1 className="text-lg font-bold text-text-primary tracking-tight">
            {currentNavItem.name}
          </h1>
        </div>
        
        {/* Role Tag */}
        <div className="px-2.5 py-1 bg-accent/15 border border-accent/30 rounded flex items-center gap-1.5">
          <ShieldCheck size={14} className="text-accent" />
          <span className="text-[10px] font-bold text-accent tracking-wide uppercase">HOD</span>
        </div>
      </header>

      {/* ─── Drawer Overlay ─── */}
      {drawerOpen && (
        <div 
          className="fixed inset-0 bg-black/60 z-30 transition-opacity"
          onClick={() => setDrawerOpen(false)}
        />
      )}

      {/* ─── Drawer Sidebar ─── */}
      <div 
        className={`fixed inset-y-0 left-0 w-[280px] bg-surface-elevated shadow-2xl z-40 transform transition-transform duration-300 ease-in-out flex flex-col ${
          drawerOpen ? "translate-x-0" : "-translate-x-full"
        }`}
      >
        <div className="p-6 pb-4 flex items-center justify-between border-b border-border">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-full bg-ai-badge-gradient flex items-center justify-center">
              <span className="text-white font-bold text-lg">H</span>
            </div>
            <div>
              <h2 className="text-lg font-extrabold text-text-primary tracking-tight">AIML Hub.</h2>
              <p className="text-xs text-text-tertiary">Admin Portal</p>
            </div>
          </div>
          <button onClick={() => setDrawerOpen(false)} className="text-text-tertiary hover:text-text-primary">
            <X size={20} />
          </button>
        </div>

        <nav className="flex-1 overflow-y-auto py-4 px-3 flex flex-col gap-1">
          {navItems.map((item) => {
            const isActive = pathname === item.href;
            return (
              <Link 
                key={item.name} 
                href={item.href}
                onClick={() => setDrawerOpen(false)}
                className={`flex items-center gap-3 px-3 py-2.5 rounded-lg transition-colors ${
                  isActive 
                    ? "bg-accent text-white font-bold shadow-sm" 
                    : "text-text-secondary font-medium hover:bg-primary-container"
                }`}
              >
                <item.icon size={20} className={isActive ? "text-white" : "text-text-secondary"} />
                <span className="text-sm">{item.name}</span>
              </Link>
            );
          })}
        </nav>

        <div className="p-4 border-t border-border">
          <button 
            onClick={() => router.push("/login")}
            className="w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-error hover:bg-error/10 transition-colors font-semibold text-sm"
          >
            <LogOut size={20} />
            Sign Out
          </button>
        </div>
      </div>

      {/* ─── Main Content ─── */}
      <main className="flex-1">
        {children}
      </main>

    </div>
  );
}
