"use client";

import { useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { ArrowLeft, Search, X, Calendar as CalendarIcon, MapPin, Users, CheckCircle } from "lucide-react";

export default function EventsHub() {
  const [selectedSegment, setSelectedSegment] = useState<0 | 1 | 2>(0);
  const [searchQuery, setSearchQuery] = useState("");

  const segments = ["Upcoming", "Past", "My Registrations"];

  // Dummy data
  const events = [
    {
      id: "ev1",
      title: "Neural Hack 2026 — 24hr AI Build Sprint",
      tag: "Hackathon",
      date: "Sep 15 · 9:00 AM – Sep 16",
      venue: "Main Auditorium, Block C",
      image: "/assets/images/event_hackathon.jpg",
      day: "15",
      month: "SEP",
      filledSeats: 42,
      totalSeats: 50,
      isRegistered: true,
      isPast: false
    },
    {
      id: "ev2",
      title: "Hands-on: Fine-tuning LLMs with LoRA",
      tag: "Workshop",
      date: "Sep 22 · 2:00 PM – 5:00 PM",
      venue: "Lab 3, Dept of AI & ML",
      image: "/assets/images/event_workshop.jpg",
      day: "22",
      month: "SEP",
      filledSeats: 28,
      totalSeats: 40,
      isRegistered: false,
      isPast: false
    },
    {
      id: "ev3",
      title: "Vision Transformers in Medical Imaging",
      tag: "Seminar",
      date: "Sep 29 · 10:30 AM – 12:00 PM",
      venue: "Seminar Hall 2",
      image: "/assets/images/event_seminar.jpg",
      day: "29",
      month: "SEP",
      filledSeats: 15,
      totalSeats: 60,
      isRegistered: false,
      isPast: false
    }
  ];

  return (
    <div className="flex flex-col min-h-screen bg-primary-surface">
      {/* ─── App Bar ─── */}
      <header className="px-5 pt-5 flex items-center gap-4">
        <Link 
          href="/" 
          className="w-10 h-10 rounded-lg bg-surface-elevated border border-border flex items-center justify-center text-text-secondary hover:bg-primary-container transition"
        >
          <ArrowLeft size={20} />
        </Link>
        <h1 className="text-xl font-bold text-text-primary tracking-tight">Events Hub</h1>
      </header>

      {/* ─── Search Bar ─── */}
      <div className="px-5 pt-4">
        <div className="relative">
          <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
            <Search size={18} className="text-text-tertiary" />
          </div>
          <input
            type="text"
            className="w-full h-11 pl-10 pr-10 bg-surface-elevated border border-border rounded-lg text-[13px] text-text-primary placeholder:text-text-tertiary focus:outline-none focus:ring-2 focus:ring-accent"
            placeholder="Search events..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
          {searchQuery && (
            <button 
              className="absolute inset-y-0 right-0 pr-3 flex items-center text-text-tertiary hover:text-text-primary"
              onClick={() => setSearchQuery("")}
            >
              <X size={16} />
            </button>
          )}
        </div>
      </div>

      {/* ─── Segmented Control ─── */}
      <div className="px-5 pt-4 pb-2">
        <div className="flex p-1 bg-primary-container rounded-lg">
          {segments.map((label, i) => (
            <button
              key={i}
              onClick={() => setSelectedSegment(i as 0 | 1 | 2)}
              className={`flex-1 py-2 text-xs font-semibold rounded-md transition-all duration-200 ${
                selectedSegment === i 
                  ? "bg-surface-elevated text-text-primary shadow-sm" 
                  : "text-text-tertiary hover:text-text-secondary"
              }`}
            >
              {label}
            </button>
          ))}
        </div>
      </div>

      {/* ─── Event List ─── */}
      <div className="px-5 pt-2 pb-12 flex flex-col gap-4">
        {events.map((event) => (
          <EventCard key={event.id} event={event} />
        ))}
      </div>
    </div>
  );
}

function EventCard({ event }: { event: any }) {
  const getTagStyle = (tag: string) => {
    const t = tag.toLowerCase();
    if (t.includes('hackathon')) return { bg: 'bg-primary/10', color: 'text-primary' };
    if (t.includes('workshop')) return { bg: 'bg-success/10', color: 'text-success' };
    return { bg: 'bg-accent/10', color: 'text-accent' };
  };

  const tagStyle = getTagStyle(event.tag);
  const ratio = event.filledSeats / event.totalSeats;
  const isFull = event.filledSeats >= event.totalSeats;
  const isNear = ratio >= 0.8;
  const barColor = isFull ? 'bg-error' : isNear ? 'bg-warning' : 'bg-accent';
  const barBg = isFull ? 'bg-error/15' : isNear ? 'bg-warning/15' : 'bg-accent/15';
  const seatColorText = isFull ? 'text-error' : isNear ? 'text-warning' : 'text-accent';

  return (
    <Link href={`/events/${event.id}`} className="block">
      <div className="rounded-xl bg-surface-elevated border border-border shadow-sm overflow-hidden hover:border-accent/50 transition">
        {/* Banner */}
        <div className="h-[140px] relative w-full">
          <Image src={event.image} alt={event.title} fill className="object-cover" />
          <div className="absolute inset-0 bg-gradient-to-t from-primary/50 to-transparent" />
          
          <div className="absolute top-2.5 left-2.5 bg-surface-elevated rounded flex flex-col items-center justify-center px-2 py-1 shadow-sm min-w-[36px]">
            <span className="text-base font-extrabold text-text-primary leading-[1.1]">{event.day}</span>
            <span className="text-[9px] font-semibold text-accent tracking-widest">{event.month}</span>
          </div>
          
          {event.isPast && (
            <div className="absolute top-2.5 right-2.5 bg-primary/80 rounded-full px-2.5 py-1">
              <span className="text-[10px] font-semibold text-white/70 tracking-wide">PAST</span>
            </div>
          )}
          
          {event.isRegistered && !event.isPast && (
            <div className="absolute top-2.5 right-2.5 bg-success/90 rounded-full px-2.5 py-1 flex items-center gap-1">
              <CheckCircle size={12} className="text-white" />
              <span className="text-[10px] font-semibold text-white tracking-wide">REGISTERED</span>
            </div>
          )}
        </div>
        
        {/* Content */}
        <div className="p-4">
          <div className={`inline-flex px-2 py-0.5 rounded text-[10px] font-semibold tracking-wide uppercase ${tagStyle.bg} ${tagStyle.color}`}>
            {event.tag}
          </div>
          
          <h3 className="text-[15px] font-bold text-text-primary leading-snug line-clamp-2 mt-2">
            {event.title}
          </h3>
          
          <div className="flex items-center gap-2 text-text-tertiary mt-2.5">
            <CalendarIcon size={14} />
            <span className="text-xs">{event.date}</span>
          </div>
          <div className="flex items-center gap-2 text-text-tertiary mt-1.5">
            <MapPin size={14} />
            <span className="text-xs truncate">{event.venue}</span>
          </div>
          
          {/* Progress */}
          <div className="mt-3">
            <div className="flex justify-between items-center mb-1.5">
              <div className={`flex items-center gap-1 ${seatColorText}`}>
                <Users size={14} />
                <span className="text-xs font-semibold">{event.filledSeats}/{event.totalSeats} seats</span>
              </div>
              {isFull && <span className="text-[10px] font-bold text-error uppercase">Sold Out</span>}
              {isNear && !isFull && <span className="text-[10px] font-bold text-warning uppercase">Filling Fast</span>}
            </div>
            <div className={`h-1.5 w-full rounded-full ${barBg}`}>
              <div 
                className={`h-full rounded-full ${barColor}`} 
                style={{ width: `${Math.min(ratio * 100, 100)}%` }}
              />
            </div>
          </div>
        </div>
      </div>
    </Link>
  );
}
