import ProjectForm from "@/components/ProjectForm";
import { requireUser } from "@/lib/firebase/session";

/** Students submit projects (spec §5); other roles are sent home server-side. */
export default async function NewProjectPage() {
  await requireUser(["student"]);
  return <ProjectForm />;
}
