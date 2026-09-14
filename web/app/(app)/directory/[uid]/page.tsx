import PublicProfile from "@/components/PublicProfile";

export default async function DirectoryProfilePage({ params }: { params: Promise<{ uid: string }> }) {
  const { uid } = await params;
  return <PublicProfile uid={uid} />;
}
