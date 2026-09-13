"use client";

import { useState } from "react";
import Link from "next/link";
import { ArrowLeft, Settings, Edit, LogOut, Ticket, UploadCloud, CalendarCheck, ChevronRight } from "lucide-react";
import { useRouter } from "next/navigation";

export default function ProfileScreen() {
  const router = useRouter();
  const [isLoggingOut, setIsLoggingOut] = useState(false);

  const handleLogout = () => {
    setIsLoggingOut(true);
    // Simulate logout
    setTimeout(() => {
      router.push("/login");
    }, 1000);
  };

  return (
    <div className="flex flex-col min-h-screen bg-primary-surface pb-16">
      {/* ─── App Bar ─── */}
      <header className="px-5 pt-5 pb-2 flex items-center justify-between">
        <Link 
          href="/" 
          className="w-10 h-10 rounded-lg bg-surface-elevated border border-border flex items-center justify-center text-text-secondary hover:bg-primary-container transition"
        >
          <ArrowLeft size={20} />
        </Link>
        <h1 className="text-[18px] font-bold text-text-primary">My Dashboard</h1>
        <button className="w-10 h-10 rounded-lg bg-surface-elevated border border-border flex items-center justify-center text-text-secondary hover:bg-primary-container transition">
          <Settings size={20} />
        </button>
      </header>

      {/* ─── Profile Header ─── */}
      <div className="px-5 py-3">
        <div className="p-5 rounded-2xl bg-surface-elevated border border-border shadow-sm flex items-center gap-5">
          {/* Avatar */}
          <div className="w-[72px] h-[72px] shrink-0 rounded-full bg-ai-badge-gradient flex items-center justify-center shadow-sm">
            <span className="text-white font-bold text-[28px]">CK</span>
          </div>

          {/* Details */}
          <div className="flex-1 min-w-0">
            <h2 className="text-[20px] font-extrabold text-text-primary truncate">Chethan Kotian</h2>
            <div className="mt-1 inline-block px-2 py-1 bg-primary-container rounded text-[11px] font-bold text-accent tracking-wide">
              USN: 4SM21CS001
            </div>
            <p className="text-[13px] text-text-secondary mt-1">3rd Year · 2024</p>
          </div>

          {/* Edit Icon */}
          <button className="p-2.5 bg-primary-container rounded-full border border-border text-accent shrink-0 hover:bg-accent hover:text-white transition">
            <Edit size={18} />
          </button>
        </div>
      </div>

      {/* ─── Action Buttons ─── */}
      <div className="px-5 py-2 flex gap-3">
        <button className="flex-1 py-3 bg-accent text-white rounded-lg font-semibold text-[13px] flex items-center justify-center gap-2 shadow-sm hover:opacity-90 transition">
          <Edit size={16} />
          Edit Profile
        </button>
        <button 
          onClick={handleLogout}
          disabled={isLoggingOut}
          className="px-5 py-3 bg-error/10 text-error border border-error/25 rounded-lg font-semibold text-[13px] flex items-center justify-center gap-2 hover:bg-error/20 transition disabled:opacity-70"
        >
          {isLoggingOut ? (
            <div className="w-4 h-4 border-2 border-error border-t-transparent rounded-full animate-spin" />
          ) : (
            <>
              <LogOut size={16} />
              Logout
            </>
          )}
        </button>
      </div>

      {/* ─── Settings / Dashboard List ─── */}
      <div className="px-5 pt-6 flex flex-col gap-3">
        <h3 className="text-[15px] font-bold text-text-primary mb-1">Activity</h3>
        
        <DashboardListItem 
          icon={Ticket}
          title="My Tickets"
          subtitle="View event registrations and QR codes"
          color="text-accent"
          bgColor="bg-accent/10"
        />
        <DashboardListItem 
          icon={UploadCloud}
          title="My Uploads"
          subtitle="Manage your projects and memory frames"
          color="text-secondary"
          bgColor="bg-secondary/10"
        />
        <DashboardListItem 
          icon={CalendarCheck}
          title="Attendance Requests"
          subtitle="Track your OD and attendance status"
          color="text-success"
          bgColor="bg-success/10"
        />
      </div>
    </div>
  );
}

function DashboardListItem({ icon: Icon, title, subtitle, color, bgColor }: any) {
  return (
    <button className="flex items-center gap-4 p-4 rounded-xl bg-surface-elevated border border-border shadow-sm hover:border-accent/50 transition w-full text-left">
      <div className={`w-12 h-12 rounded-full flex items-center justify-center shrink-0 ${bgColor}`}>
        <Icon size={20} className={color} />
      </div>
      <div className="flex-1 min-w-0">
        <h4 className="text-[15px] font-bold text-text-primary">{title}</h4>
        <p className="text-[12px] text-text-tertiary mt-0.5 truncate">{subtitle}</p>
      </div>
      <ChevronRight size={20} className="text-text-tertiary shrink-0" />
    </button>
  );
}
