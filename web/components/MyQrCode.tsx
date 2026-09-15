"use client";

import { useEffect, useRef } from "react";
import QRCode from "qrcode";

/**
 * A student's personal check-in QR — just their uid, generated entirely
 * client-side (no network call, no expiry). A coordinator/faculty/HOD
 * scans it during an event; POST /api/attendance/scan validates and
 * records it server-side, so this code being static/shareable doesn't
 * matter — only staff scanning it (and the student being registered for
 * that event) produces an attendance record.
 */
export default function MyQrCode({ uid, size = 220 }: { uid: string; size?: number }) {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    if (!canvasRef.current) return;
    QRCode.toCanvas(canvasRef.current, uid, {
      width: size,
      margin: 1,
      color: { dark: "#0E1B3D", light: "#FFFFFF" },
    }).catch(() => {});
  }, [uid, size]);

  return (
    <div className="inline-block rounded-lg border border-border bg-white p-4 shadow-sm">
      <canvas ref={canvasRef} width={size} height={size} />
    </div>
  );
}
