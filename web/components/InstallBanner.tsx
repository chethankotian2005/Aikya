"use client";

import { useEffect, useState } from "react";
import { Download, X } from "lucide-react";

export function InstallBanner() {
  const [deferredPrompt, setDeferredPrompt] = useState<any>(null);
  const [showBanner, setShowBanner] = useState(false);
  const [isIOS, setIsIOS] = useState(false);

  useEffect(() => {
    // Check if already in standalone mode or dismissed in this session
    const isStandalone = window.matchMedia("(display-mode: standalone)").matches;
    const dismissed = sessionStorage.getItem("pwa-banner-dismissed");

    if (isStandalone || dismissed) {
      return;
    }

    // Check for iOS
    const userAgent = window.navigator.userAgent.toLowerCase();
    const isIosDevice = /iphone|ipad|ipod/.test(userAgent);
    setIsIOS(isIosDevice);

    const handleBeforeInstallPrompt = (e: Event) => {
      e.preventDefault();
      setDeferredPrompt(e);
      setShowBanner(true);
    };

    window.addEventListener("beforeinstallprompt", handleBeforeInstallPrompt);

    // If iOS, we show the fallback instruction banner immediately since there's no event
    if (isIosDevice) {
      setShowBanner(true);
    }

    return () => {
      window.removeEventListener("beforeinstallprompt", handleBeforeInstallPrompt);
    };
  }, []);

  const handleInstallClick = async () => {
    if (!deferredPrompt) return;

    deferredPrompt.prompt();
    const { outcome } = await deferredPrompt.userChoice;
    
    if (outcome === "accepted") {
      setShowBanner(false);
      setDeferredPrompt(null);
    }
  };

  const handleDismiss = () => {
    sessionStorage.setItem("pwa-banner-dismissed", "true");
    setShowBanner(false);
  };

  if (!showBanner) return null;

  return (
    <div className="bg-primary text-on-primary p-4 flex items-center justify-between shadow-md">
      <div className="flex items-center gap-3">
        <div className="bg-on-primary/10 p-2 rounded-lg">
          <Download size={20} className="text-accent" />
        </div>
        <div>
          <p className="font-semibold text-sm">Install Aikya</p>
          <p className="text-xs text-on-primary/70">
            {isIOS 
              ? "Tap Share → Add to Home Screen" 
              : "Get the app for a better experience"}
          </p>
        </div>
      </div>
      <div className="flex items-center gap-2">
        {!isIOS && (
          <button
            onClick={handleInstallClick}
            className="bg-accent hover:bg-accent-hover text-on-primary text-sm font-medium px-4 py-1.5 rounded-full transition-colors"
          >
            Install
          </button>
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
