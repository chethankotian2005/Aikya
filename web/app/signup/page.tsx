"use client";

import { useState } from "react";
import { createUserWithEmailAndPassword } from "firebase/auth";
import { doc, setDoc, serverTimestamp } from "firebase/firestore";
import { auth, db } from "@/lib/firebase/firebase";
import { useRouter } from "next/navigation";
import Image from "next/image";

const USN_REGEX = /^4MW[0-9]{2}AI[0-9]{3}$/;

export default function SignupPage() {
  const router = useRouter();
  const [fullName, setFullName] = useState("");
  const [usn, setUsn] = useState("");
  const [phone, setPhone] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSignup = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    const sanitizedUsn = usn.trim().toUpperCase().replace(/\s+/g, "");
    if (!USN_REGEX.test(sanitizedUsn)) {
      setError("Invalid USN format. Expected format: 4MW21AI042");
      return;
    }
    if (password.length < 6) {
      setError("Password must be at least 6 characters.");
      return;
    }
    if (password !== confirmPassword) {
      setError("Passwords do not match.");
      return;
    }

    setLoading(true);
    try {
      const email = `${sanitizedUsn.toLowerCase()}@aikya.smvitm.edu`;

      const userCredential = await createUserWithEmailAndPassword(auth, email, password);
      const uid = userCredential.user.uid;

      await setDoc(doc(db, "users", uid), {
        email,
        usn: sanitizedUsn,
        fullName: fullName.trim(),
        role: "student",
        ...(phone.trim() ? { phone: phone.trim() } : {}),
        createdAt: serverTimestamp(),
      });

      const idToken = await userCredential.user.getIdToken();
      const res = await fetch("/api/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ idToken }),
      });

      if (!res.ok) {
        const data = await res.json().catch(() => ({}));
        throw new Error(data.error || "Account created, but failed to sign you in. Please log in.");
      }

      router.push("/");
      router.refresh();
    } catch (err: any) {
      if (err.code === "auth/email-already-in-use") {
        setError("This USN is already registered. Please log in instead.");
      } else {
        setError(err.message || "Failed to sign up");
      }
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-primary-surface flex flex-col items-center justify-center p-4 relative overflow-hidden">
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
          <h1 className="text-2xl font-bold text-text-primary mb-2">Create your account</h1>
          <p className="text-text-secondary text-sm text-center">Sign up with your USN to get started</p>
        </div>

        <form onSubmit={handleSignup} className="space-y-5">
          <div>
            <label className="block text-sm font-medium text-text-secondary mb-1">Full Name</label>
            <input
              type="text"
              className="w-full px-4 py-2.5 border border-border rounded-lg bg-primary-surface focus:outline-none focus:ring-2 focus:ring-accent"
              value={fullName}
              onChange={(e) => setFullName(e.target.value)}
              placeholder="e.g. Jane Doe"
              required
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-text-secondary mb-1">USN</label>
            <input
              type="text"
              className="w-full px-4 py-2.5 border border-border rounded-lg bg-primary-surface focus:outline-none focus:ring-2 focus:ring-accent"
              value={usn}
              onChange={(e) => setUsn(e.target.value)}
              placeholder="e.g. 4MW21AI042"
              required
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-text-secondary mb-1">Phone (optional)</label>
            <input
              type="tel"
              className="w-full px-4 py-2.5 border border-border rounded-lg bg-primary-surface focus:outline-none focus:ring-2 focus:ring-accent"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              placeholder="e.g. 9876543210"
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
              minLength={6}
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-text-secondary mb-1">Confirm Password</label>
            <input
              type="password"
              className="w-full px-4 py-2.5 border border-border rounded-lg bg-primary-surface focus:outline-none focus:ring-2 focus:ring-accent"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              required
              minLength={6}
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
              "Sign Up"
            )}
          </button>
        </form>

        <div className="mt-8 text-center text-sm">
          <span className="text-text-secondary">Already have an account? </span>
          <a href="/login" className="text-accent font-bold hover:underline">Login</a>
        </div>
      </div>
    </div>
  );
}
