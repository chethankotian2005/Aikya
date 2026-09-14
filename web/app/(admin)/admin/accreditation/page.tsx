import AccreditationCompiler from "@/components/admin/AccreditationCompiler";
import { requireUser } from "@/lib/firebase/session";

export default async function AccreditationPage() {
  await requireUser(["hod"]);
  return <AccreditationCompiler />;
}
