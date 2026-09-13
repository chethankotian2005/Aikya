"use client";

import { initializeApp, getApps, getApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import { getStorage } from "firebase/storage";
import { getMessaging, isSupported } from "firebase/messaging";

const firebaseConfig = {
  apiKey: "AIzaSyAUq0Fwz6ubqzKP2Gmn430g8F-cn1Ajc3g",
  authDomain: "aikya-platform.firebaseapp.com",
  projectId: "aikya-platform",
  storageBucket: "aikya-platform.firebasestorage.app",
  messagingSenderId: "287187127448",
  appId: "1:287187127448:web:8191d0f72f3eae13c514ed",
  measurementId: "G-WTT4W33VXZ"
};

// Initialize Firebase
const app = getApps().length > 0 ? getApp() : initializeApp(firebaseConfig);

const auth = getAuth(app);
const db = getFirestore(app);
const storage = getStorage(app);

// Messaging may not be supported in all environments (like SSR)
const messaging = async () => {
  const supported = await isSupported();
  return supported ? getMessaging(app) : null;
};

export { app, auth, db, storage, messaging };
