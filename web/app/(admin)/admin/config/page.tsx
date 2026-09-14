import BatchConfig from "@/components/admin/BatchConfig";
import { requireUser } from "@/lib/firebase/session";

export default async function BatchConfigPage() {
  await requireUser(["hod"]);
  return <BatchConfig />;
}
