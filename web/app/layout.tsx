import type { Metadata } from "next";
import { Poppins } from "next/font/google";
import "./globals.css";

const poppins = Poppins({
  variable: "--font-poppins",
  subsets: ["latin"],
  weight: ["400", "500", "600", "700"],
});

import { InstallBanner } from "@/components/InstallBanner";

export const metadata: Metadata = {
  title: "Aikya | Connect & Grow",
  description: "AIKYA connects students, alumni, and faculty in a unified platform.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="en"
      className={`${poppins.variable} h-full antialiased`}
    >
      <body className="min-h-full flex flex-col">
        <InstallBanner />
        <main className="flex-1 flex flex-col">{children}</main>
      </body>
    </html>
  );
}
