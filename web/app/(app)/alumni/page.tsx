"use client";

import { useState } from "react";
import Link from "next/link";
import { ArrowLeft, Search, MapPin, Handshake, ChevronRight, GraduationCap } from "lucide-react";

// Dummy data
const dummyAlumni = [
  {
    id: "a1",
    name: "Vikram R.",
    initials: "VR",
    jobTitle: "Senior ML Engineer",
    company: "Google",
    graduationYear: "2020",
    location: "Bengaluru, India",
    isOpenForMentorship: true,
  },
  {
    id: "a2",
    name: "Anjali M.",
    initials: "AM",
    jobTitle: "Data Scientist",
    company: "Amazon",
    graduationYear: "2021",
    location: "Hyderabad, India",
    isOpenForMentorship: false,
  },
  {
    id: "a3",
    name: "Rohit K.",
    initials: "RK",
    jobTitle: "AI Researcher",
    company: "Microsoft",
    graduationYear: "2019",
    location: "Seattle, USA",
    isOpenForMentorship: true,
  }
];

export default function AlumniScreen() {
  const [searchQuery, setSearchQuery] = useState("");

  const filteredAlumni = dummyAlumni.filter(a => 
    a.name.toLowerCase().includes(searchQuery.toLowerCase()) || 
    a.company.toLowerCase().includes(searchQuery.toLowerCase()) ||
    a.jobTitle.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="flex flex-col min-h-screen bg-primary-surface pb-16">
      {/* ─── App Bar ─── */}
      <header className="px-5 pt-5 flex items-center gap-4">
        <Link 
          href="/" 
          className="w-10 h-10 rounded-lg bg-surface-elevated border border-border flex items-center justify-center text-text-secondary hover:bg-primary-container transition"
        >
          <ArrowLeft size={20} />
        </Link>
        <h1 className="text-xl font-bold text-text-primary tracking-tight">Alumni Network</h1>
      </header>

      {/* ─── Search Bar ─── */}
      <div className="px-5 py-4">
        <div className="relative">
          <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
            <Search size={18} className="text-text-tertiary" />
          </div>
          <input
            type="text"
            className="w-full h-11 pl-10 bg-surface-elevated border border-border rounded-lg text-[13px] text-text-primary placeholder:text-text-tertiary focus:outline-none focus:ring-2 focus:ring-accent"
            placeholder="Search by name, role, or company..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>
      </div>

      {/* ─── Alumni List ─── */}
      <div className="px-5 pb-10 flex flex-col gap-4">
        {filteredAlumni.length === 0 ? (
          <div className="py-10 flex flex-col items-center justify-center text-text-tertiary">
            <GraduationCap size={48} className="mb-4 opacity-50" />
            <p className="text-sm">No alumni found</p>
          </div>
        ) : (
          filteredAlumni.map(alumni => (
            <AlumniCard key={alumni.id} alumni={alumni} />
          ))
        )}
      </div>
    </div>
  );
}

function AlumniCard({ alumni }: { alumni: any }) {
  return (
    <div className="rounded-xl bg-surface-elevated border border-border p-4 shadow-sm hover:border-accent/50 transition cursor-pointer">
      <div className="flex items-start gap-4">
        {/* Avatar */}
        <div className="w-14 h-14 shrink-0 rounded-full bg-ai-badge-gradient flex items-center justify-center shadow-sm mt-1">
          <span className="text-white font-bold text-lg">{alumni.initials}</span>
        </div>

        {/* Details */}
        <div className="flex-1 min-w-0">
          <div className="flex justify-between items-start">
            <h4 className="text-[16px] font-bold text-text-primary truncate pr-2">{alumni.name}</h4>
            <ChevronRight size={18} className="text-text-tertiary shrink-0 mt-0.5" />
          </div>
          
          <p className="text-[13px] font-semibold text-text-secondary mt-0.5 truncate">
            {alumni.jobTitle} @ {alumni.company}
          </p>
          
          <p className="text-[11px] text-text-tertiary mt-1">
            Batch of {alumni.graduationYear}
          </p>

          <div className="flex flex-wrap gap-2 mt-3">
            {alumni.isOpenForMentorship && (
              <div className="px-2 py-1 bg-accent/10 border border-accent/20 rounded text-[10px] font-bold text-accent flex items-center gap-1">
                <Handshake size={12} />
                Open to Mentor
              </div>
            )}
            <div className="px-2 py-1 bg-primary-container rounded text-[10px] font-medium text-text-secondary flex items-center gap-1">
              <MapPin size={12} />
              {alumni.location}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
