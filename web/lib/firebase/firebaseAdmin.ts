import { initializeApp, getApps, cert, applicationDefault } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";

const serviceAccountStr = process.env.FIREBASE_SERVICE_ACCOUNT;
const serviceAccount = serviceAccountStr ? JSON.parse(serviceAccountStr) : undefined;

if (getApps().length === 0) {
  initializeApp({
    credential: serviceAccount ? cert(serviceAccount) : applicationDefault(),
    storageBucket: process.env.FIREBASE_STORAGE_BUCKET || "aikya-platform.firebasestorage.app",
  });
}

export const adminAuth = getAuth();
export const adminDb = getFirestore();
export const adminStorage = getStorage();
