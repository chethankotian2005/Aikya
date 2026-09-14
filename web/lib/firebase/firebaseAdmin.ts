import { initializeApp, getApps, cert, applicationDefault } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";

let credential: any;
try {
  const serviceAccountStr = process.env.FIREBASE_SERVICE_ACCOUNT;
  if (serviceAccountStr) {
    // Check if it was pasted with surrounding quotes by Vercel
    let parsed = serviceAccountStr;
    if (parsed.startsWith('"') && parsed.endsWith('"')) {
      parsed = parsed.slice(1, -1).replace(/\\"/g, '"');
    }
    let json;
    try {
      // Normal case: valid JSON (e.g. pretty-printed with real newlines
      // between properties, and a properly escaped \n inside private_key).
      json = JSON.parse(parsed);
    } catch {
      // Fallback: some paste flows leave raw newlines inside the
      // private_key value itself, which breaks JSON string escaping.
      json = JSON.parse(parsed.replace(/\n/g, '\\n'));
    }
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

// Don't crash on import if credential is not valid
let app: any;
try {
  if (getApps().length === 0) {
    app = initializeApp({
      credential,
      storageBucket: process.env.FIREBASE_STORAGE_BUCKET || "aikya-platform.firebasestorage.app",
    });
  } else {
    app = getApps()[0];
  }
} catch (error) {
  console.error("Error initializing Firebase Admin app:", error);
}

// Provide a safe getter for auth
export const getAdminAuth = () => {
  if (!app) throw new Error("Firebase Admin app is not initialized. Check your credentials.");
  return getAuth(app);
};

export const getAdminDb = () => {
  if (!app) throw new Error("Firebase Admin app is not initialized. Check your credentials.");
  return getFirestore(app);
};

export const getAdminStorage = () => {
  if (!app) throw new Error("Firebase Admin app is not initialized. Check your credentials.");
  return getStorage(app);
};
