import UpdateComposer from "@/components/UpdateComposer";
import { requireUser } from "@/lib/firebase/session";

/** Faculty / coordinator / HOD "Post Update" composer (spec §6). */
export default async function NewUpdatePage() {
  await requireUser(["faculty", "coordinator", "hod"]);
  return <UpdateComposer />;
}
