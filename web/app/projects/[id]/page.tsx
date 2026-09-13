export default async function ProjectDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  return (
    <div className="flex-1 p-6">
      <h1 className="text-3xl font-bold mb-4">Project Detail</h1>
      <p className="text-text-secondary">Project ID: {id}</p>
    </div>
  );
}
