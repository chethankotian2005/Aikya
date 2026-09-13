"use client";

import { useState } from "react";
import { signInWithEmailAndPassword, updatePassword } from "firebase/auth";
import { auth, db } from "@/lib/firebase/firebase";
import { doc, getDoc, updateDoc } from "firebase/firestore";
import { useRouter } from "next/navigation";
import Image from "next/image";

export default function LoginPage() {
  const router = useRouter();
  const [role, setRole] = useState<"student" | "faculty">("student");
  const [idValue, setIdValue] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [needsReset, setNeedsReset] = useState(false);
  const [newPassword, setNewPassword] = useState("");

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      let loginEmail = idValue;
      
      // Faculty logic
      if (role === "faculty") {
        const sanitizedId = idValue.trim().toLowerCase().replace(/\s+/g, '');
        loginEmail = `${sanitizedId}@aikya.internal`;
      } 
      // Student logic (USN to Email)
      else if (role === "student") {
        const sanitizedUsn = idValue.trim().toLowerCase().replace(/\s+/g, '');
        loginEmail = `${sanitizedUsn}@aikya.smvitm.edu`;
      }

      const userCredential = await signInWithEmailAndPassword(auth, loginEmail, password);
      
      if (role === "faculty") {
        const userDoc = await getDoc(doc(db, "users", userCredential.user.uid));
        if (userDoc.exists() && userDoc.data()?.needsPasswordReset) {
          setNeedsReset(true);
          setLoading(false);
          return;
        }
      }

      await finalizeLogin(userCredential.user);
    } catch (err: any) {
      setError(err.message || "Failed to login");
      setLoading(false);
    }
  };

  const handleResetSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      if (!auth.currentUser) throw new Error("No user found");
      
      await updatePassword(auth.currentUser, newPassword);
      await updateDoc(doc(db, "users", auth.currentUser.uid), {
        needsPasswordReset: false
      });
      
      await finalizeLogin(auth.currentUser);
    } catch (err: any) {
      setError(err.message || "Failed to reset password");
      setLoading(false);
    }
  };

  const finalizeLogin = async (user: any) => {
    // Get Firebase ID Token
    const idToken = await user.getIdToken();
    
    // Call our API route to set the secure session cookie
    const res = await fetch("/api/login", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ idToken }),
    });

    if (res.ok) {
      router.push("/");
      router.refresh();
    } else {
      throw new Error("Failed to create session");
    }
  };

  if (needsReset) {
    return (
      <div className="min-h-screen bg-primary-surface flex items-center justify-center p-4">
        <div className="bg-surface-elevated max-w-md w-full p-8 rounded-xl shadow-lg border border-border">
          <h2 className="text-2xl font-semibold text-text-primary mb-2">Update Password</h2>
          <p className="text-text-secondary text-sm mb-6">
            For security reasons, you must change your default password before accessing your account.
          </p>
          <form onSubmit={handleResetSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-text-secondary mb-1">New Password</label>
              <input
                type="password"
                className="w-full px-3 py-2 border border-border rounded-lg bg-primary-surface focus:outline-none focus:ring-2 focus:ring-accent"
                value={newPassword}
                onChange={(e) => setNewPassword(e.target.value)}
                required
                minLength={6}
              />
            </div>
            {error && <p className="text-error text-sm">{error}</p>}
            <button
              type="submit"
              disabled={loading}
              className="w-full bg-secondary hover:bg-accent-hover text-on-primary py-2.5 rounded-lg font-medium transition-colors"
            >
              {loading ? "Updating..." : "Update Password & Login"}
            </button>
          </form>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-primary-surface flex flex-col items-center justify-center p-4 relative overflow-hidden">
      {/* Decorative Wave Overlay */}
      <div className="absolute inset-0 bg-wave-motif pointer-events-none" />
      
      <div className="bg-surface-elevated max-w-md w-full p-8 rounded-xl shadow-lg border border-border z-10 relative">
        
        <div className="flex flex-col items-center mb-6">
          <Image 
            src="/aikya_logo_cropped.png" 
            alt="Aikya Logo" 
            width={160} 
            height={80} 
            className="mb-4 object-contain"
          />
          <h1 className="text-2xl font-bold text-text-primary mb-2">Welcome to AIKYA</h1>
          <p className="text-text-secondary text-sm text-center">
            {role === "student" ? "Login with your USN to continue" : "Login with your Faculty ID to continue"}
          </p>
        </div>

        {/* Segmented Control */}
        <div className="flex p-1 bg-primary-container rounded-lg mb-8">
          <button
            type="button"
            className={`flex-1 py-2 text-sm font-medium rounded-md transition-colors ${role === "student" ? "bg-surface-elevated shadow-sm text-text-primary" : "text-text-secondary hover:text-text-primary"}`}
            onClick={() => setRole("student")}
          >
            Student
          </button>
          <button
            type="button"
            className={`flex-1 py-2 text-sm font-medium rounded-md transition-colors ${role === "faculty" ? "bg-surface-elevated shadow-sm text-text-primary" : "text-text-secondary hover:text-text-primary"}`}
            onClick={() => setRole("faculty")}
          >
            Faculty
          </button>
        </div>

        <form onSubmit={handleLogin} className="space-y-5">
          <div>
            <label className="block text-sm font-medium text-text-secondary mb-1">
              {role === "student" ? "USN" : "Faculty ID"}
            </label>
            <input
              type="text"
              className="w-full px-4 py-2.5 border border-border rounded-lg bg-primary-surface focus:outline-none focus:ring-2 focus:ring-accent"
              value={idValue}
              onChange={(e) => setIdValue(e.target.value)}
              placeholder={role === "student" ? "e.g. 4MW20CS001" : "e.g. 0544"}
              required
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-text-secondary mb-1">Password</label>
            <input
              type="password"
              className="w-full px-4 py-2.5 border border-border rounded-lg bg-primary-surface focus:outline-none focus:ring-2 focus:ring-accent"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>
          
          {error && <p className="text-error text-sm font-medium">{error}</p>}
          
          <button
            type="submit"
            disabled={loading}
            className="w-full bg-secondary hover:bg-accent-hover text-on-primary py-3 mt-2 rounded-lg font-medium transition-colors flex justify-center items-center"
          >
            {loading ? (
              <svg className="animate-spin h-5 w-5 text-on-primary" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
            ) : (
              "Login"
            )}
          </button>
        </form>

        {role === "student" && (
          <div className="mt-8 text-center text-sm">
            <span className="text-text-secondary">New User? </span>
            <a href="/signup" className="text-accent font-bold hover:underline">Sign Up</a>
          </div>
        )}
      </div>
    </div>
  );
}
