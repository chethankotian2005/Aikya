"use client";

import { useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { ArrowLeft, Search, UserPlus, ChevronRight, User, Plus, FolderOpen } from "lucide-react";

// Dummy data for projects
const dummyProjects = [
  {
    id: "p1",
    title: "Autonomous Drone Navigation",
    author: "Rahul S.",
    image: "/assets/images/proj_drone.jpg",
    tags: ["Computer Vision", "ROS", "Python"],
    lookingForTeammate: true,
  },
  {
    id: "p2",
    title: "Predictive Maintenance for Industrial Robots",
    author: "Neha K.",
    image: "/assets/images/proj_robot.jpg",
    tags: ["Time Series", "IoT", "TensorFlow"],
    lookingForTeammate: false,
  },
  {
    id: "p3",
    title: "Medical Image Segmentation (MRI)",
    author: "Aditya V.",
    image: "/assets/images/proj_medical.jpg",
    tags: ["Healthcare", "PyTorch", "U-Net"],
    lookingForTeammate: true,
  },
  {
    id: "p4",
    title: "Algorithmic Trading Bot",
    author: "Sneha M.",
    image: "/assets/images/proj_stock.jpg",
    tags: ["Finance", "RL", "Python"],
    lookingForTeammate: false,
  }
];

// Dummy data for students
const dummyStudents = [
  {
    id: "s1",
    name: "Rahul S.",
    year: "3rd",
    batch: "2024",
    skills: ["Python", "ROS", "TensorFlow"],
    initials: "RS"
  },
  {
    id: "s2",
    name: "Neha K.",
    year: "4th",
    batch: "2023",
    skills: ["IoT", "Data Science", "SQL"],
    initials: "NK"
  },
  {
    id: "s3",
    name: "Aditya V.",
    year: "3rd",
    batch: "2024",
    skills: ["PyTorch", "Computer Vision"],
    initials: "AV"
  }
];

export default function ProjectsScreen() {
  const [activeTab, setActiveTab] = useState<"showcase" | "directory">("showcase");
  const [selectedTag, setSelectedTag] = useState("All");
  const [searchQuery, setSearchQuery] = useState("");

  const availableTags = ["All", "Computer Vision", "Finance", "Healthcare", "IoT", "PyTorch", "Python", "RL", "ROS", "TensorFlow", "Time Series", "U-Net"];

  const filteredProjects = selectedTag === "All" 
    ? dummyProjects 
    : dummyProjects.filter(p => p.tags.includes(selectedTag));

  const filteredStudents = dummyStudents.filter(s => 
    s.name.toLowerCase().includes(searchQuery.toLowerCase()) || 
    s.skills.some(skill => skill.toLowerCase().includes(searchQuery.toLowerCase()))
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
        <h1 className="text-xl font-bold text-text-primary tracking-tight">Projects</h1>
      </header>

      {/* ─── Tab Bar ─── */}
      <div className="px-5 pt-4 pb-2">
        <div className="flex p-1 bg-surface-elevated rounded-xl border border-border shadow-sm">
          <button
            onClick={() => setActiveTab("showcase")}
            className={`flex-1 py-2 text-sm font-semibold rounded-lg transition-all duration-200 ${
              activeTab === "showcase"
                ? "bg-accent text-white shadow-sm"
                : "text-text-secondary hover:text-text-primary"
            }`}
          >
            Showcase
          </button>
          <button
            onClick={() => setActiveTab("directory")}
            className={`flex-1 py-2 text-sm font-semibold rounded-lg transition-all duration-200 ${
              activeTab === "directory"
                ? "bg-accent text-white shadow-sm"
                : "text-text-secondary hover:text-text-primary"
            }`}
          >
            Directory
          </button>
        </div>
      </div>

      {activeTab === "showcase" ? (
        <div className="flex-1 flex flex-col">
          {/* ─── Filter Bar ─── */}
          <div className="w-full overflow-x-auto no-scrollbar py-3">
            <div className="flex px-5 gap-2 min-w-max">
              {availableTags.map(tag => (
                <button
                  key={tag}
                  onClick={() => setSelectedTag(tag)}
                  className={`px-4 py-2 rounded-full border text-[13px] transition-colors ${
                    selectedTag === tag 
                      ? "bg-accent border-accent text-white font-semibold" 
                      : "bg-surface-elevated border-border text-text-secondary font-medium hover:bg-primary-container"
                  }`}
                >
                  {tag}
                </button>
              ))}
            </div>
          </div>

          {/* ─── Masonry Grid (Approximation) ─── */}
          <div className="px-5 pb-10 columns-2 gap-4">
            {filteredProjects.length === 0 ? (
              <div className="col-span-2 py-10 flex flex-col items-center justify-center text-text-tertiary">
                <FolderOpen size={48} className="mb-4 opacity-50" />
                <p className="text-sm">No projects found for "{selectedTag}"</p>
              </div>
            ) : (
              filteredProjects.map((project, i) => (
                <ProjectTile key={project.id} project={project} />
              ))
            )}
          </div>
        </div>
      ) : (
        <div className="flex-1 flex flex-col">
          {/* ─── Search Bar ─── */}
          <div className="px-5 py-3">
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <Search size={18} className="text-text-tertiary" />
              </div>
              <input
                type="text"
                className="w-full h-11 pl-10 bg-surface-elevated border border-border rounded-lg text-[13px] text-text-primary placeholder:text-text-tertiary focus:outline-none focus:ring-2 focus:ring-accent"
                placeholder="Search by name or skills..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
              />
            </div>
          </div>

          {/* ─── Student List ─── */}
          <div className="px-5 pb-10 flex flex-col gap-3">
            {filteredStudents.length === 0 ? (
              <div className="py-10 flex flex-col items-center justify-center text-text-tertiary">
                <User size={48} className="mb-4 opacity-50" />
                <p className="text-sm">No students found</p>
              </div>
            ) : (
              filteredStudents.map(student => (
                <StudentCard key={student.id} student={student} />
              ))
            )}
          </div>
        </div>
      )}

      {/* Floating Action Button */}
      <button className="fixed bottom-20 right-5 bg-accent text-white px-5 py-3.5 rounded-full shadow-lg shadow-accent/25 flex items-center gap-2 hover:bg-accent-hover transition z-40">
        <Plus size={20} strokeWidth={2.5} />
        <span className="text-sm font-semibold">Submit Project</span>
      </button>
    </div>
  );
}

function ProjectTile({ project }: { project: any }) {
  return (
    <Link href={`/projects/detail/${project.id}`} className="block break-inside-avoid mb-4">
      <div className="rounded-xl bg-surface-elevated border border-border shadow-sm overflow-hidden hover:border-accent/50 transition relative">
        
        {/* Image */}
        <div className="relative w-full aspect-[4/5] bg-primary-container">
          <Image src={project.image} alt={project.title} fill className="object-cover" />
          
          {/* Teammate Badge */}
          {project.lookingForTeammate && (
            <div className="absolute top-2 right-2 bg-primary/85 border border-accent/50 rounded-full px-2 py-1 flex items-center gap-1 backdrop-blur-sm">
              <UserPlus size={10} className="text-accent" />
              <span className="text-[9px] font-bold text-accent tracking-wider">TEAMMATE</span>
            </div>
          )}
        </div>

        {/* Details */}
        <div className="p-3">
          <h4 className="text-sm font-bold text-text-primary leading-snug line-clamp-2">
            {project.title}
          </h4>
          <p className="text-[11px] font-medium text-text-tertiary mt-1">
            by {project.author}
          </p>
          
          {/* Tech Stack Chips */}
          <div className="flex flex-wrap gap-1.5 mt-2.5">
            {project.tags.map((tag: string) => (
              <div key={tag} className="px-1.5 py-0.5 bg-primary-container rounded text-[9px] font-semibold text-text-secondary">
                {tag}
              </div>
            ))}
          </div>
        </div>
      </div>
    </Link>
  );
}

function StudentCard({ student }: { student: any }) {
  return (
    <Link href={`/directory/profile/${student.id}`} className="block">
      <div className="rounded-xl bg-surface-elevated border border-border p-4 flex items-center gap-4 shadow-sm hover:border-accent/50 transition">
        
        {/* Avatar */}
        <div className="w-12 h-12 shrink-0 rounded-full bg-ai-badge-gradient flex items-center justify-center shadow-sm">
          <span className="text-white font-bold text-lg">{student.initials}</span>
        </div>

        {/* Details */}
        <div className="flex-1 min-w-0">
          <h4 className="text-[15px] font-bold text-text-primary truncate">{student.name}</h4>
          <p className="text-xs text-text-secondary mt-0.5">{student.year} Year, {student.batch}</p>
          <div className="flex flex-wrap gap-1.5 mt-2">
            {student.skills.slice(0, 3).map((skill: string) => (
              <div key={skill} className="px-1.5 py-0.5 bg-primary-container rounded text-[9px] font-semibold text-text-secondary border border-border/50">
                {skill}
              </div>
            ))}
          </div>
        </div>

        <ChevronRight size={20} className="text-text-tertiary shrink-0" />
      </div>
    </Link>
  );
}
