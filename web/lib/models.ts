import { Timestamp } from "firebase/firestore";

/** Roles from spec §5. */
export type Role = "student" | "faculty" | "coordinator" | "hod";

export const ROLE_LABELS: Record<Role, string> = {
  student: "Student",
  faculty: "Faculty",
  coordinator: "Coordinator",
  hod: "HOD",
};

/** The five clubs a coordinator can lead (spec §5). */
export const CLUBS = ["Aikya", "IEEE", "ISTE", "Co-curricular", "Extra-curricular"] as const;

export const USN_PATTERN = /^4MW\d{2}AI\d{3}$/;

export const isStaff = (role?: Role | null) => !!role && role !== "student";
export const canBuildEvents = (role?: Role | null) => role === "hod" || role === "coordinator";

export function toRole(value: unknown): Role {
  return value === "faculty" || value === "coordinator" || value === "hod" ? value : "student";
}

/** Reads a date stored as a Timestamp (current writes) or ISO string (older writes). */
export function toDate(value: unknown): Date | null {
  if (value instanceof Timestamp) return value.toDate();
  if (value instanceof Date) return value;
  if (typeof value === "string") {
    const d = new Date(value);
    return Number.isNaN(d.getTime()) ? null : d;
  }
  return null;
}

const str = (v: unknown) => (typeof v === "string" ? v : "");
const optStr = (v: unknown) => (typeof v === "string" && v ? v : null);
const strList = (v: unknown) => (Array.isArray(v) ? v.filter((x): x is string => typeof x === "string") : []);
const num = (v: unknown) => (typeof v === "number" ? v : 0);

export interface UserProfile {
  uid: string;
  email: string;
  usn: string;
  fullName: string;
  role: Role;
  profileComplete: boolean;
  mustResetPassword: boolean;
  phone: string | null;
  bio: string | null;
  skills: string[];
  githubUrl: string | null;
  linkedinUrl: string | null;
  instagramHandle: string | null;
  personalWebsite: string | null;
  twitterHandle: string | null;
  discordHandle: string | null;
  profilePictureUrl: string | null;
  yearOfStudy: string | null;
  batch: string | null;
  status: string | null;
  designation: string | null;
  club: string | null;
  facultyId: string | null;
  privacySettings: Record<string, boolean>;
  notificationSettings: Record<string, boolean>;
}

export function toProfile(uid: string, d: Record<string, unknown>): UserProfile {
  return {
    uid,
    email: str(d.email),
    usn: str(d.usn),
    fullName: str(d.fullName),
    role: toRole(d.role),
    profileComplete: d.profileComplete === true,
    mustResetPassword: d.mustResetPassword === true,
    phone: optStr(d.phone),
    bio: optStr(d.bio),
    skills: strList(d.skills),
    githubUrl: optStr(d.githubUrl),
    linkedinUrl: optStr(d.linkedinUrl),
    instagramHandle: optStr(d.instagramHandle),
    personalWebsite: optStr(d.personalWebsite),
    twitterHandle: optStr(d.twitterHandle),
    discordHandle: optStr(d.discordHandle),
    profilePictureUrl: optStr(d.profilePictureUrl),
    yearOfStudy: d.yearOfStudy == null ? null : String(d.yearOfStudy),
    batch: optStr(d.batch),
    status: optStr(d.status),
    designation: optStr(d.designation),
    club: optStr(d.club),
    facultyId: optStr(d.facultyId),
    privacySettings: (d.privacySettings as Record<string, boolean>) ?? {},
    notificationSettings: (d.notificationSettings as Record<string, boolean>) ?? {},
  };
}

export type FieldType = "text" | "email" | "phone" | "dropdown" | "multiline";

export interface RegistrationField {
  label: string;
  hint: string;
  type: FieldType;
  options: string[];
  required: boolean;
}

function toFields(schema: unknown): RegistrationField[] {
  const fields = schema && typeof schema === "object" && "fields" in schema ? (schema as { fields: unknown }).fields : schema;
  if (!Array.isArray(fields)) return [];
  return fields
    .filter((f): f is Record<string, unknown> => !!f && typeof f === "object")
    .map((f) => ({
      label: str(f.label) || "Question",
      hint: str(f.hint),
      type: (["text", "email", "phone", "dropdown", "multiline"].includes(f.type as string) ? f.type : "text") as FieldType,
      options: strList(f.options),
      required: f.required !== false,
    }));
}

export interface EventItem {
  id: string;
  title: string;
  description: string;
  venue: string;
  eventDate: Date;
  endDate: Date | null;
  maxCapacity: number;
  currentRegistrations: number;
  registrationDeadline: Date;
  formFields: RegistrationField[];
  tag: string;
  club: string | null;
  bannerUrl: string | null;
  createdBy: string;
  reportMarkdown: string | null;
  sentiment: { positive: number; neutral: number; negative: number } | null;
}

export function toEvent(id: string, d: Record<string, unknown>): EventItem {
  const eventDate = toDate(d.eventDate) ?? new Date();
  const report = d.report as Record<string, unknown> | undefined;
  const sentiment = (d.sentiment as Record<string, unknown> | undefined)?.percentages as
    | EventItem["sentiment"]
    | undefined;
  return {
    id,
    title: str(d.title) || "Untitled event",
    description: str(d.description),
    venue: str(d.venue),
    eventDate,
    endDate: toDate(d.endDate),
    maxCapacity: num(d.maxCapacity),
    currentRegistrations: num(d.currentRegistrations),
    registrationDeadline: toDate(d.registrationDeadline) ?? eventDate,
    formFields: toFields(d.customFormSchema),
    tag: str(d.tag) || "General",
    club: optStr(d.club),
    bannerUrl: optStr(d.bannerUrl),
    createdBy: str(d.createdBy),
    reportMarkdown: optStr(report?.markdown),
    sentiment: sentiment ?? null,
  };
}

export const eventIsPast = (e: EventItem) => (e.endDate ?? e.eventDate).getTime() < Date.now();
export const eventIsFull = (e: EventItem) => e.currentRegistrations >= e.maxCapacity;
export const eventFillRatio = (e: EventItem) => (e.maxCapacity > 0 ? e.currentRegistrations / e.maxCapacity : 0);
export const eventIsOpen = (e: EventItem) =>
  !eventIsFull(e) && !eventIsPast(e) && Date.now() < e.registrationDeadline.getTime();

export interface ProjectItem {
  id: string;
  title: string;
  description: string;
  techStack: string[];
  images: string[];
  ownerUid: string;
  ownerName: string;
  contributors: string[];
  lookingForTeammate: boolean;
  repoUrl: string | null;
}

export function toProject(id: string, d: Record<string, unknown>): ProjectItem {
  return {
    id,
    title: str(d.title) || "Untitled project",
    description: str(d.description),
    techStack: strList(d.techStack),
    images: strList(d.images),
    ownerUid: str(d.ownerUid),
    ownerName: str(d.ownerName),
    contributors: strList(d.contributors),
    lookingForTeammate: d.lookingForTeammate === true,
    repoUrl: optStr(d.repoUrl),
  };
}

export type FrameStatus = "pending" | "approved" | "rejected";

export interface MemoryFrame {
  id: string;
  uploadedBy: string;
  uploaderName: string;
  imageUrl: string;
  caption: string;
  eventName: string;
  eventId: string | null;
  status: FrameStatus;
  likesCount: number;
  reportMarkdown: string | null;
  createdAt: Date | null;
}

export function toFrame(id: string, d: Record<string, unknown>): MemoryFrame {
  const status = d.status === "approved" || d.status === "rejected" ? d.status : "pending";
  return {
    id,
    uploadedBy: str(d.uploadedBy),
    uploaderName: str(d.uploaderName) || "AIKYA member",
    imageUrl: str(d.imageUrl),
    caption: str(d.caption),
    eventName: str(d.eventName),
    eventId: optStr(d.eventId),
    status,
    likesCount: num(d.likesCount),
    reportMarkdown: optStr(d.reportMarkdown),
    createdAt: toDate(d.createdAt),
  };
}

export interface AttendanceRequest {
  id: string;
  studentId: string;
  eventId: string;
  requestDetails: string;
  status: FrameStatus;
  reviewNotes: string | null;
  createdAt: Date | null;
}

export function toAttendance(id: string, d: Record<string, unknown>): AttendanceRequest {
  const status = d.status === "approved" || d.status === "rejected" ? d.status : "pending";
  return {
    id,
    studentId: str(d.studentId),
    eventId: str(d.eventId),
    requestDetails: str(d.requestDetails),
    status,
    reviewNotes: optStr(d.reviewNotes),
    createdAt: toDate(d.createdAt),
  };
}

export interface UpdateItem {
  id: string;
  content: string;
  authorId: string;
  authorName: string;
  authorDesignation: string;
  club: string | null;
  imageUrl: string | null;
  deadlineDate: Date | null;
  createdAt: Date | null;
}

export function toUpdate(id: string, d: Record<string, unknown>): UpdateItem {
  return {
    id,
    content: str(d.content),
    authorId: str(d.authorId),
    authorName: str(d.authorName) || "Department",
    authorDesignation: str(d.authorDesignation),
    club: optStr(d.club),
    imageUrl: optStr(d.imageUrl),
    deadlineDate: toDate(d.deadlineDate),
    createdAt: toDate(d.createdAt),
  };
}

export interface AlumniProfile {
  uid: string;
  fullName: string;
  graduationYear: number | null;
  currentCompany: string;
  jobTitle: string;
  location: string;
  linkedinUrl: string | null;
  bio: string | null;
  isOpenForMentorship: boolean;
  verifiedByHod: boolean;
}

export function toAlumni(uid: string, d: Record<string, unknown>): AlumniProfile {
  return {
    uid,
    fullName: str(d.fullName) || "AIKYA Alumni",
    graduationYear: typeof d.graduationYear === "number" ? d.graduationYear : null,
    currentCompany: str(d.currentCompany),
    jobTitle: str(d.jobTitle),
    location: str(d.location),
    linkedinUrl: optStr(d.linkedinUrl),
    bio: optStr(d.bio),
    isOpenForMentorship: d.isOpenForMentorship === true,
    verifiedByHod: d.verifiedByHod === true,
  };
}

export interface CommentItem {
  id: string;
  userId: string;
  userName: string;
  commentText: string;
  createdAt: Date | null;
}

export function toComment(id: string, d: Record<string, unknown>): CommentItem {
  return {
    id,
    userId: str(d.userId),
    userName: str(d.userName) || "Member",
    commentText: str(d.commentText),
    createdAt: toDate(d.createdAt),
  };
}

export function initials(name: string): string {
  const letters = name
    .trim()
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((p) => p[0])
    .join("")
    .toUpperCase();
  return letters || "?";
}

const MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

export function formatDateTime(d: Date): string {
  const hour = d.getHours() % 12 || 12;
  const minute = String(d.getMinutes()).padStart(2, "0");
  return `${MONTHS[d.getMonth()]} ${d.getDate()}, ${d.getFullYear()} · ${hour}:${minute} ${d.getHours() >= 12 ? "PM" : "AM"}`;
}

export function formatDate(d: Date): string {
  return `${d.getDate()} ${MONTHS[d.getMonth()]} ${d.getFullYear()}`;
}

export function monthShort(d: Date): string {
  return MONTHS[d.getMonth()].toUpperCase();
}

export function timeAgo(d: Date | null): string {
  if (!d) return "just now";
  const seconds = Math.round((Date.now() - d.getTime()) / 1000);
  if (seconds < 60) return "just now";
  const minutes = Math.round(seconds / 60);
  if (minutes < 60) return `${minutes}m ago`;
  const hours = Math.round(minutes / 60);
  if (hours < 24) return `${hours}h ago`;
  const days = Math.round(hours / 24);
  if (days < 7) return `${days}d ago`;
  return formatDate(d);
}

/** Year-of-study estimate from the USN admission year (display only; the backend's batch table is authoritative). */
export function detectYear(usn: string): string {
  const match = USN_PATTERN.exec(usn.toUpperCase()) && usn.toUpperCase().match(/^4MW(\d{2})AI/);
  if (!match) return "Unknown";
  const now = new Date();
  const academicYear = now.getMonth() >= 7 ? now.getFullYear() : now.getFullYear() - 1;
  const year = academicYear - (2000 + Number(match[1])) + 1;
  if (year > 4) return "Alumni";
  return ["1st Year", "2nd Year", "3rd Year", "Final Year"][Math.max(year, 1) - 1];
}
