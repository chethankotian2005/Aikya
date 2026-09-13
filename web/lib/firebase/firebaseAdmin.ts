import { initializeApp, getApps, cert, applicationDefault } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";

let credential;
try {
  const serviceAccountStr = process.env.FIREBASE_SERVICE_ACCOUNT;
  if (serviceAccountStr) {
    // Check if it was pasted with surrounding quotes by Vercel
    let parsed = serviceAccountStr;
    if (parsed.startsWith('"') && parsed.endsWith('"')) {
      parsed = parsed.slice(1, -1).replace(/\\"/g, '"');
    }
    const json = JSON.parse(parsed);
    credential = cert(json);
  } else if (process.env.FIREBASE_PROJECT_ID && process.env.FIREBASE_PRIVATE_KEY && process.env.FIREBASE_CLIENT_EMAIL) {
    credential = cert({
      projectId: process.env.FIREBASE_PROJECT_ID,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
    });
  }
} catch (error) {
  console.error("Error parsing Firebase Admin credentials:", error);
}

try {
  if (getApps().length === 0) {
    initializeApp({
      credential, // can be undefined, will throw if used without credentials later, but won't crash on boot
      storageBucket: process.env.FIREBASE_STORAGE_BUCKET || "aikya-platform.firebasestorage.app",
    });
  }
} catch (error) {
  console.error("Error initializing Firebase Admin app:", error);
}

export const adminAuth = getAuth();
export const adminDb = getFirestore();
export const adminStorage = getStorage();
