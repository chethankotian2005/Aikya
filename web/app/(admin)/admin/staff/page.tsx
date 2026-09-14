import StaffProvisioning from "@/components/admin/StaffProvisioning";
import { requireUser } from "@/lib/firebase/session";

export default async function StaffPage() {
  await requireUser(["hod"]);
  return <StaffProvisioning />;
}
