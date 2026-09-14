import ModerationQueue from "@/components/admin/ModerationQueue";
import { requireUser } from "@/lib/firebase/session";

export default async function ModerationPage() {
  await requireUser(["hod"]);
  return <ModerationQueue />;
}
