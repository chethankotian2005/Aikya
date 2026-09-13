"use client";

import Image from "next/image";
import { Search, Bell, Folder, Calendar, Users, GraduationCap, Star, ThumbsUp, MessageSquare, MoreHorizontal, Clock, User as UserIcon } from "lucide-react";
import Link from "next/link";

export default function Home() {
  const hour = new Date().getHours();
  const greeting = hour < 12 ? "Good morning" : hour < 17 ? "Good afternoon" : "Good evening";

  return (
    <div className="flex flex-col min-h-screen bg-primary-surface">
      {/* ─── Header ─── */}
      <header className="px-5 pt-5 pb-2 flex items-center">
        <div className="relative w-11 h-11 rounded-full bg-ai-badge-gradient flex items-center justify-center shadow-sm">
          <span className="text-white font-bold text-lg">CK</span>
          <div className="absolute bottom-0 right-0 w-3 h-3 rounded-full bg-success border-2 border-primary-surface"></div>
        </div>
        <div className="flex-1 ml-4">
          <p className="text-xs font-medium text-text-tertiary">{greeting}</p>
          <h1 className="text-lg font-bold text-text-primary tracking-tight leading-tight truncate">Chethan Kotian</h1>
        </div>
        <div className="flex gap-2">
          <button className="w-10 h-10 rounded-lg bg-surface-elevated border border-border flex items-center justify-center text-text-secondary hover:bg-primary-container transition">
            <Search size={20} />
          </button>
          <button className="relative w-10 h-10 rounded-lg bg-surface-elevated border border-border flex items-center justify-center text-text-secondary hover:bg-primary-container transition">
            <Bell size={20} />
            <span className="absolute top-1.5 right-1.5 w-2.5 h-2.5 rounded-full bg-error border-[1.5px] border-surface-elevated"></span>
          </button>
        </div>
      </header>

      {/* ─── Stat Strip ─── */}
      <div className="w-full overflow-x-auto no-scrollbar pt-2 pb-4">
        <div className="flex px-5 gap-3 min-w-max">
          <StatPill icon={Folder} value="12" label="Active Projects" bgColor="bg-accent/10" iconColor="text-accent" />
          <StatPill icon={Calendar} value="5" label="Upcoming Events" bgColor="bg-secondary/10" iconColor="text-secondary" />
          <StatPill icon={Users} value="148" label="Dept. Members" bgColor="bg-success/10" iconColor="text-success" />
          <StatPill icon={GraduationCap} value="320+" label="Alumni" bgColor="bg-warning/10" iconColor="text-warning" />
        </div>
      </div>

      {/* ─── Upcoming Events ─── */}
      <SectionHeader title="Upcoming Events" actionLabel="View all" href="/events" />
      <div className="w-full overflow-x-auto no-scrollbar pb-4">
        <div className="flex px-5 gap-4 min-w-max">
          <EventCard 
            image="/assets/images/event_hackathon.jpg"
            day="15" month="SEP" seats="42/50"
            tag="HACKATHON" tagBg="bg-accent/10" tagColor="text-accent"
            title="Neural Hack 2026 — 24hr AI Build Sprint"
            time="Sep 15 · 9:00 AM – Sep 16"
          />
          <EventCard 
            image="/assets/images/event_workshop.jpg"
            day="22" month="SEP" seats="28/40"
            tag="WORKSHOP" tagBg="bg-secondary/10" tagColor="text-secondary"
            title="Hands-on: Fine-tuning LLMs with LoRA"
            time="Sep 22 · 2:00 PM – 5:00 PM"
          />
          <EventCard 
            image="/assets/images/event_seminar.jpg"
            day="29" month="SEP" seats="15/60"
            tag="SEMINAR" tagBg="bg-warning/10" tagColor="text-warning"
            title="Vision Transformers in Medical Imaging"
            time="Sep 29 · 10:30 AM – 12:00 PM"
          />
        </div>
      </div>

      {/* ─── Recent Activity ─── */}
      <SectionHeader title="Recent Activity" actionLabel="Filter" href="#" />
      <div className="px-5 flex flex-col gap-4 pb-12">
        {/* Pinned Announcement */}
        <div className="rounded-xl border border-[#331F5C99] bg-gradient-to-br from-primary to-secondary p-0 overflow-hidden shadow-sm">
          <div className="p-4 flex gap-3">
            <div className="w-9 h-9 rounded-full bg-primary flex items-center justify-center shrink-0">
              <span className="text-white text-sm font-bold">RN</span>
            </div>
            <div className="flex-1 min-w-0">
              <h4 className="text-sm font-semibold text-white/90">Dr. Rajesh Nayak</h4>
              <p className="text-[11px] text-white/40">HOD · AI & ML</p>
            </div>
            <span className="text-[11px] text-white/40">2h ago</span>
          </div>
          <div className="px-4 pb-3">
            <div className="inline-flex items-center gap-1 bg-accent/20 px-2 py-0.5 rounded text-[10px] font-semibold text-accent mb-2 tracking-wide">
              <Star size={11} className="fill-accent" /> PINNED
            </div>
            <p className="text-[13px] text-white/80 leading-relaxed">
              <span className="font-semibold text-white/95">NBA Accreditation prep: </span>
              All 6th-sem students — upload your project abstracts by Sep 10. COs must be mapped. Coordinate with your project guide.
            </p>
          </div>
          <div className="px-4 pb-4 flex gap-4">
            <ReactionBtn icon={ThumbsUp} label="24" color="text-white/40" />
            <ReactionBtn icon={MessageSquare} label="8 replies" color="text-white/40" />
          </div>
        </div>

        {/* AI Digest */}
        <div className="rounded-xl border border-[#331F5C99] bg-surface-elevated shadow-sm">
          <div className="p-4 flex gap-3">
            <div className="w-9 h-9 rounded-full bg-ai-badge-gradient flex items-center justify-center shrink-0">
              <span className="text-white text-sm">✦</span>
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-1.5">
                <h4 className="text-sm font-semibold text-text-primary">Weekly Digest</h4>
                <div className="bg-ai-badge-gradient rounded text-[9px] font-bold text-white px-1.5 py-0.5 tracking-wider">AI</div>
              </div>
              <p className="text-[11px] text-text-tertiary">Auto-generated by Gemini</p>
            </div>
            <span className="text-[11px] text-text-tertiary">Today</span>
          </div>
          <div className="px-4 pb-3">
            <p className="text-[13px] text-text-secondary leading-relaxed">
              This week: <span className="font-semibold text-text-primary">3 new project proposals</span> submitted, <span className="font-semibold text-text-primary">Neural Hack</span> registrations at 84% capacity, and the department published <span className="font-semibold text-text-primary">2 research papers</span> in IEEE Access. Sentiment across 12 feedback forms: mostly positive (87%).
            </p>
          </div>
          <div className="px-4 pb-4 flex gap-4">
            <ReactionBtn icon={ThumbsUp} label="16" />
            <ReactionBtn icon={MoreHorizontal} label="More" />
          </div>
        </div>

        {/* Compact Card 1 */}
        <CompactCard 
          image="/assets/images/event_hackathon.jpg"
          title="📸 Workshop Day 1 — Hands-on TensorFlow session photos uploaded"
          meta="Memory Frames · 18 photos · 4h ago"
          href="/memory"
        />

        {/* Faculty Announcement */}
        <div className="rounded-xl border border-border bg-surface-elevated shadow-sm">
          <div className="p-4 flex gap-3">
            <div className="w-9 h-9 rounded-full bg-[#1F5C99] flex items-center justify-center shrink-0">
              <span className="text-white text-sm font-bold">RP</span>
            </div>
            <div className="flex-1 min-w-0">
              <h4 className="text-sm font-semibold text-text-primary">Prof. Rashmi P.</h4>
              <p className="text-[11px] text-text-tertiary">Faculty · Machine Learning</p>
            </div>
            <span className="text-[11px] text-text-tertiary">6h ago</span>
          </div>
          <div className="px-4 pb-3">
            <p className="text-[13px] text-text-secondary leading-relaxed">
              <span className="font-semibold text-text-primary">Mini-project evaluation </span>
              rescheduled to Sep 12 (Friday). Bring hardcopy of synopsis + working demo. Teams of 2-3 only.
            </p>
          </div>
          <div className="px-4 pb-4 flex gap-4">
            <ReactionBtn icon={ThumbsUp} label="11" />
            <ReactionBtn icon={MessageSquare} label="3 replies" />
          </div>
        </div>

        {/* Compact Card 2 */}
        <CompactCard 
          image="/assets/images/event_workshop.jpg"
          title="🎓 Alumni Talk: Career paths after AI & ML — Recording available"
          meta="Memory Frames · Video · Yesterday"
          href="/memory"
        />
      </div>
    </div>
  );
}

// ─── Sub-components ───

function StatPill({ icon: Icon, value, label, bgColor, iconColor }: any) {
  return (
    <div className="flex items-center gap-2.5 py-1.5 px-3.5 bg-surface-elevated rounded-full border border-border shrink-0 shadow-sm">
      <div className={`w-7 h-7 rounded-full flex items-center justify-center ${bgColor}`}>
        <Icon size={14} className={iconColor} />
      </div>
      <div>
        <div className="text-[15px] font-bold text-text-primary leading-[1.1]">{value}</div>
        <div className="text-[10px] font-medium text-text-tertiary">{label}</div>
      </div>
    </div>
  );
}

function SectionHeader({ title, actionLabel, href }: { title: string, actionLabel: string, href: string }) {
  return (
    <div className="flex justify-between items-center px-5 pt-4 pb-3">
      <h3 className="text-[15px] font-bold text-text-primary">{title}</h3>
      <Link href={href} className="text-xs font-semibold text-accent hover:underline">
        {actionLabel}
      </Link>
    </div>
  );
}

function EventCard({ image, day, month, seats, tag, tagBg, tagColor, title, time }: any) {
  const parts = seats.split('/');
  const filled = parseInt(parts[0]);
  const total = parseInt(parts[1]);
  const ratio = filled / total;
  const isFull = filled >= total;
  const isNear = ratio >= 0.8;
  const dotColor = isFull ? "bg-error" : isNear ? "bg-warning" : "bg-success";
  const seatText = isFull ? "Full" : isNear ? `${seats} · Filling fast` : `${seats} seats`;

  return (
    <div className="w-[270px] shrink-0 rounded-xl bg-surface-elevated border border-border shadow-sm flex flex-col overflow-hidden">
      <div className="h-[120px] relative w-full">
        <Image src={image} alt={title} fill className="object-cover" />
        <div className="absolute inset-0 bg-gradient-to-t from-primary/50 to-transparent" />
        
        <div className="absolute top-2 left-2 bg-surface-elevated rounded flex flex-col items-center justify-center px-2 py-1 shadow-sm min-w-[36px]">
          <span className="text-base font-extrabold text-text-primary leading-[1.1]">{day}</span>
          <span className="text-[9px] font-semibold text-accent tracking-widest">{month}</span>
        </div>
        
        <div className="absolute bottom-2 right-2 bg-primary/75 rounded-full px-2.5 py-1 flex items-center gap-1">
          <div className={`w-1.5 h-1.5 rounded-full ${dotColor}`} />
          <UserIcon size={12} className="text-white/90" />
          <span className="text-[11px] font-semibold text-white ml-0.5">{seatText}</span>
        </div>
      </div>
      
      <div className="p-3.5 flex flex-col gap-1.5">
        <div className={`self-start px-2 py-0.5 rounded text-[10px] font-semibold tracking-wide ${tagBg} ${tagColor}`}>
          {tag}
        </div>
        <h4 className="text-sm font-bold text-text-primary leading-tight line-clamp-2">{title}</h4>
        <div className="flex items-center gap-1 text-text-tertiary mt-0.5">
          <Clock size={12} />
          <span className="text-[11px] truncate">{time}</span>
        </div>
      </div>
    </div>
  );
}

function ReactionBtn({ icon: Icon, label, color = "text-text-tertiary" }: any) {
  return (
    <button className={`flex items-center gap-1.5 ${color} hover:opacity-80 transition`}>
      <Icon size={16} />
      <span className="text-xs font-medium">{label}</span>
    </button>
  );
}

function CompactCard({ image, title, meta, href }: any) {
  return (
    <Link href={href} className="flex rounded-xl bg-surface-elevated border border-border shadow-sm overflow-hidden hover:bg-primary-surface/50 transition">
      <div className="w-20 h-20 shrink-0 relative">
        <Image src={image} alt="Thumbnail" fill className="object-cover" />
      </div>
      <div className="p-3 flex flex-col justify-center min-w-0">
        <h4 className="text-[13px] font-semibold text-text-primary leading-[1.35] line-clamp-2 mb-0.5">{title}</h4>
        <p className="text-[11px] text-text-tertiary truncate">{meta}</p>
      </div>
    </Link>
  );
}
