"use client";

import { CalendarCheck, FileQuestion, ShieldAlert, Users } from "lucide-react";

export default function AdminDashboard() {
  return (
    <div className="p-5 flex flex-col h-[calc(100vh-64px)]">
      <div className="mb-6">
        <h2 className="text-2xl font-extrabold text-text-primary tracking-tight">Overview</h2>
        <p className="text-[13px] text-text-secondary mt-1">
          Welcome back. Here is the department status at a glance.
        </p>
      </div>

      <div className="flex-1 grid grid-cols-2 gap-4 auto-rows-max">
        <StatCard 
          icon={CalendarCheck} 
          title="Active Events" 
          value="3" 
          color="text-accent" 
          bgColor="bg-accent/15" 
          borderColor="border-accent/20"
        />
        <StatCard 
          icon={FileQuestion} 
          title="Pending Leaves" 
          value="14" 
          color="text-warning" 
          bgColor="bg-warning/15" 
          borderColor="border-warning/20"
        />
        <StatCard 
          icon={ShieldAlert} 
          title="Mod Queue" 
          value="5" 
          color="text-error" 
          bgColor="bg-error/15" 
          borderColor="border-error/20"
        />
        <StatCard 
          icon={Users} 
          title="Active Students" 
          value="142" 
          color="text-success" 
          bgColor="bg-success/15" 
          borderColor="border-success/20"
        />
      </div>
    </div>
  );
}

function StatCard({ icon: Icon, title, value, color, bgColor, borderColor }: any) {
  return (
    <div className="p-4 rounded-xl bg-surface-elevated border border-border shadow-sm flex flex-col justify-between aspect-[1.1]">
      <div className={`w-11 h-11 rounded-full flex items-center justify-center ${bgColor} ${borderColor} border`}>
        <Icon size={24} className={color} />
      </div>
      <div>
        <h3 className="text-[28px] font-extrabold text-text-primary leading-[1.1]">{value}</h3>
        <p className="text-xs font-semibold text-text-secondary mt-1">{title}</p>
      </div>
    </div>
  );
}
