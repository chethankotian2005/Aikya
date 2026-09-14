import AttendanceQueue from "@/components/admin/AttendanceQueue";
import { requireUser } from "@/lib/firebase/session";

export default async function AttendancePage() {
  await requireUser(["hod"]);
  return <AttendanceQueue />;
}
