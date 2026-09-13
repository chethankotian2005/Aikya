"use client";

import Image from "next/image";
import Link from "next/link";
import { ArrowLeft, Filter, Camera, FileText } from "lucide-react";

// Dummy data
const dummyMemories = [
  {
    id: "m1",
    imageUrl: "/assets/images/event_hackathon.jpg",
    uploadedBy: "Rahul S.",
    isTall: true,
    hasReport: true,
  },
  {
    id: "m2",
    imageUrl: "/assets/images/event_workshop.jpg",
    uploadedBy: "Neha K.",
    isTall: false,
    hasReport: false,
  },
  {
    id: "m3",
    imageUrl: "/assets/images/event_seminar.jpg",
    uploadedBy: "Aditya V.",
    isTall: false,
    hasReport: true,
  },
  {
    id: "m4",
    imageUrl: "/assets/images/proj_robot.jpg",
    uploadedBy: "Sneha M.",
    isTall: true,
    hasReport: false,
  }
];

export default function MemoryWallScreen() {
  return (
    <div className="flex flex-col min-h-screen bg-primary-surface pb-16">
      {/* ─── Header ─── */}
      <header className="px-5 pt-5 pb-4 flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Link 
            href="/" 
            className="w-10 h-10 rounded-lg bg-surface-elevated border border-border flex items-center justify-center text-text-secondary hover:bg-primary-container transition"
          >
            <ArrowLeft size={20} />
          </Link>
          <div>
            <h1 className="text-[22px] font-extrabold text-text-primary tracking-tight leading-tight">Memory Wall</h1>
            <p className="text-[13px] text-text-secondary">Snapshots of our journey.</p>
          </div>
        </div>
        <button className="w-10 h-10 rounded-full bg-primary-container text-primary flex items-center justify-center hover:bg-accent/20 transition">
          <Filter size={18} />
        </button>
      </header>

      {/* ─── Gallery Grid (Approximation of Masonry) ─── */}
      <div className="px-5 pb-10 columns-2 gap-3">
        {dummyMemories.map((memory) => (
          <MemoryCard key={memory.id} memory={memory} />
        ))}
      </div>

      {/* Floating Action Button */}
      <button className="fixed bottom-20 right-5 bg-accent text-white px-5 py-3.5 rounded-full shadow-lg shadow-accent/25 flex items-center gap-2 hover:bg-accent-hover transition z-40">
        <Camera size={20} strokeWidth={2.5} />
        <span className="text-sm font-semibold">Contribute</span>
      </button>
    </div>
  );
}

function MemoryCard({ memory }: { memory: any }) {
  return (
    <div className="break-inside-avoid mb-3">
      <div className={`relative w-full rounded-xl overflow-hidden shadow-sm border border-border bg-surface-elevated ${memory.isTall ? 'aspect-[3/4]' : 'aspect-square'}`}>
        <Image src={memory.imageUrl} alt="Memory" fill className="object-cover hover:scale-105 transition duration-500" />
        
        {/* Report Badge */}
        {memory.hasReport && (
          <div className="absolute top-2 right-2 bg-accent rounded-full p-1.5 shadow-sm">
            <FileText size={14} className="text-white" />
          </div>
        )}

        {/* Bottom Gradient & Details */}
        <div className="absolute inset-x-0 bottom-0 pt-10 pb-2.5 px-3 bg-gradient-to-t from-black/80 to-transparent">
          <div className="flex justify-between items-center">
            <span className="text-[11px] font-semibold text-white truncate pr-2">
              {memory.uploadedBy}
            </span>
          </div>
        </div>
      </div>
    </div>
  );
}
