import {
  BookOpen, Brain, Code, Compass, Cpu, GraduationCap, Lightbulb, Puzzle,
  Rocket, Sparkles, Target, Zap, type LucideIcon,
} from "lucide-react";

/**
 * Preset avatars (spec §3 tokens only — gradient pairs + icon, no file
 * storage). Chosen instead of photo uploads since Firebase Storage requires
 * the paid Blaze plan; this keeps the app fully on the free Spark plan with
 * zero third-party dependency for images.
 */
export interface AvatarOption {
  id: number;
  icon: LucideIcon;
  gradient: [string, string];
}

const GRADIENTS: [string, string][] = [
  ["#0E1B3D", "#1F5C99"], // primary → secondary
  ["#1F5C99", "#3B9AE1"], // secondary → accent
  ["#0E1B3D", "#3B9AE1"], // primary → accent
  ["#2D8AD1", "#1F5C99"], // accent-hover → secondary
];

const ICONS: LucideIcon[] = [
  Rocket, Sparkles, Brain, GraduationCap, BookOpen, Code,
  Cpu, Compass, Zap, Target, Puzzle, Lightbulb,
];

export const AVATARS: AvatarOption[] = ICONS.map((icon, i) => ({
  id: i + 1,
  icon,
  gradient: GRADIENTS[i % GRADIENTS.length],
}));

export function avatarById(id: number | null | undefined): AvatarOption | null {
  if (id == null) return null;
  return AVATARS.find((a) => a.id === id) ?? null;
}
