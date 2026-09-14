import EventBuilder from "@/components/admin/EventBuilder";

export default async function EditEventPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  return <EventBuilder id={id} />;
}
