import BottomNav from "@/components/BottomNav";

export default function AppLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <div className="flex flex-col min-h-screen bg-primary-surface pb-16">
      {/* 
        The pb-16 is to ensure content isn't hidden behind the fixed BottomNav.
        We can also use pb-20 to be safe with safe areas.
      */}
      <main className="flex-1 pb-20">
        {children}
      </main>
      <BottomNav />
    </div>
  );
}
