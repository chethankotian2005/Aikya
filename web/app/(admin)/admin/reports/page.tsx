import ReportGenerator from "@/components/admin/ReportGenerator";

export default async function ReportsPage({ searchParams }: { searchParams: Promise<{ eventId?: string }> }) {
  const { eventId } = await searchParams;
  return <ReportGenerator initialEventId={eventId ?? ""} />;
}
