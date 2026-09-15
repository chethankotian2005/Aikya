"use client";

import { useEffect, useState } from "react";
import { Download, X } from "lucide-react";

// Overwritten on every successful push to main by .github/workflows/build-apk.yml —
// this path always resolves to the current build, no GitHub auth required
// (public repo). GitHub itself marks that redirect no-cache, but browsers
// and Android's download manager still dedupe/serve-from-cache by URL, so a
// cache-busting query param is appended per click to force a fresh fetch
// every time instead of silently reusing a previously downloaded file.
const APK_URL = "https://github.com/chethankotian2005/Aikya/releases/download/apk-latest/aikya.apk";

type Platform = "android" | "ios" | "other";

function detectPlatform(): Platform {
  const ua = window.navigator.userAgent.toLowerCase();
  if (/android/.test(ua)) return "android";
  if (/iphone|ipad|ipod/.test(ua)) return "ios";
  return "other";
}

/** Prompts mobile visitors to get the real Aikya Android app instead of the web build. */
export function InstallBanner() {
  const [platform, setPlatform] = useState<Platform | null>(null);
  const [showBanner, setShowBanner] = useState(false);

  useEffect(() => {
    const isStandalone = window.matchMedia("(display-mode: standalone)").matches;
    const dismissed = sessionStorage.getItem("pwa-banner-dismissed");
    if (isStandalone || dismissed) return;

    const detected = detectPlatform();
    setPlatform(detected);
    // Only Android gets a real app to download; iOS gets home-screen instructions.
    // Desktop visitors aren't prompted to install a phone app.
    setShowBanner(detected === "android" || detected === "ios");
  }, []);

  const handleDismiss = () => {
    sessionStorage.setItem("pwa-banner-dismissed", "true");
    setShowBanner(false);
  };

  const handleInstallClick = (e: React.MouseEvent) => {
    e.preventDefault();
    window.location.href = `${APK_URL}?t=${Date.now()}`;
  };

  if (!showBanner || !platform) return null;

  return (
    <div className="bg-primary text-on-primary p-4 flex items-center justify-between shadow-md">
      <div className="flex items-center gap-3">
        <div className="bg-on-primary/10 p-2 rounded-lg">
          <Download size={20} className="text-accent" />
        </div>
        <div>
          <p className="font-semibold text-sm">Install Aikya</p>
          <p className="text-xs text-on-primary/70">
            {platform === "ios" ? "Tap Share → Add to Home Screen" : "Get the Android app"}
          </p>
        </div>
      </div>
      <div className="flex items-center gap-2">
        {platform === "android" && (
          <a
            href={APK_URL}
            onClick={handleInstallClick}
            className="bg-accent hover:bg-accent-hover text-on-primary text-sm font-medium px-4 py-1.5 rounded-full transition-colors"
          >
            Install
          </a>
        )}
        <button
          onClick={handleDismiss}
          className="p-1.5 text-on-primary/50 hover:text-on-primary hover:bg-on-primary/10 rounded-full transition-colors"
          aria-label="Dismiss"
        >
          <X size={18} />
        </button>
      </div>
    </div>
  );
}
