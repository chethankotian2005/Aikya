"use client";

import { AVATARS } from "@/lib/avatars";

export default function AvatarPicker({
  value,
  onChange,
}: {
  value: number | null;
  onChange: (id: number) => void;
}) {
  return (
    <div role="radiogroup" aria-label="Choose an avatar" className="grid grid-cols-4 gap-3 sm:grid-cols-6">
      {AVATARS.map((a) => {
        const selected = a.id === value;
        const Icon = a.icon;
        return (
          <button
            key={a.id}
            type="button"
            role="radio"
            aria-checked={selected}
            aria-label={`Avatar ${a.id}`}
            onClick={() => onChange(a.id)}
            className="relative h-14 w-14 shrink-0 rounded-full transition"
            style={{
              background: `linear-gradient(135deg, ${a.gradient[0]}, ${a.gradient[1]})`,
              outline: selected ? "3px solid var(--color-accent)" : "3px solid transparent",
              outlineOffset: "2px",
            }}
          >
            <Icon size={28} className="absolute inset-0 m-auto text-white" strokeWidth={2} aria-hidden />
          </button>
        );
      })}
    </div>
  );
}
