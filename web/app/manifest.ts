import { MetadataRoute } from "next";

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: "Aikya Web",
    short_name: "Aikya",
    description: "Aikya connects students, alumni, and faculty in a unified platform.",
    start_url: "/",
    display: "standalone",
    background_color: "#0E1B3D",
    theme_color: "#0E1B3D",
    icons: [
      {
        src: "/icon-192x192.png",
        sizes: "192x192",
        type: "image/png",
      },
      {
        src: "/icon-512x512.png",
        sizes: "512x512",
        type: "image/png",
      },
    ],
  };
}
