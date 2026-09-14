"use client";

import { useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { createUserWithEmailAndPassword, deleteUser } from "firebase/auth";
import { doc, serverTimestamp, setDoc } from "firebase/firestore";
import { auth, db } from "@/lib/firebase/firebase";
import { friendlyError } from "@/lib/errors";
import { USN_PATTERN } from "@/lib/models";
import PasswordInput from "@/components/PasswordInput";
import { ErrorText } from "@/components/ui";

export default function SignupPage() {
  const [fullName, setFullName] = useState("");
  const [usn, setUsn] = useState("");
  const [phone, setPhone] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [agreed, setAgreed] = useState(false);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSignup = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    const normalizedUsn = usn.trim().toUpperCase().replace(/\s+/g, "");
    if (!USN_PATTERN.test(normalizedUsn)) {
      setError(
        /^4MW\d{2}[A-Z]{2}\d{3}$/.test(normalizedUsn)
          ? "AIKYA is for AI & ML department students only."
          : "Invalid USN — expected e.g. 4MW21AI042.",
      );
      return;
    }
    if (password.length < 6) return setError("Password must be at least 6 characters.");
    if (password !== confirmPassword) return setError("Passwords do not match.");
    if (!agreed) return setError("Please review and agree to the data collection notice.");

    setLoading(true);
    try {
      const email = `${normalizedUsn.toLowerCase()}@aikya.smvitm.edu`;
      const credential = await createUserWithEmailAndPassword(auth, email, password);
      const user = credential.user;

      try {
        await setDoc(doc(db, "users", user.uid), {
          uid: user.uid,
          email,
          usn: normalizedUsn,
          fullName: fullName.trim(),
          role: "student",
          phone: phone.trim() || null,
          profileComplete: false,
          mustResetPassword: false,
          skills: [],
          createdAt: serverTimestamp(),
        });
      } catch (profileError) {
        // Don't leave an Auth account without a profile — it would block a retry.
        await deleteUser(user).catch(() => {});
        throw profileError;
      }

      const res = await fetch("/api/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ idToken: await user.getIdToken() }),
      });
      if (!res.ok) throw new Error("Account created, but we couldn't sign you in. Please log in.");

      window.location.href = "/setup";
    } catch (err) {
      setError(friendlyError(err));
      setLoading(false);
    }
  };

  return (
    <div className="relative flex min-h-screen flex-col items-center justify-center overflow-hidden bg-primary-surface p-4">
      <div className="pointer-events-none absolute inset-0 bg-wave-motif" />

      <div className="card relative z-10 w-full max-w-md p-8">
        <div className="mb-6 flex flex-col items-center">
          <Image src="/aikya_logo_cropped.png" alt="Aikya logo" width={160} height={80} className="mb-4 object-contain" priority />
          <h1 className="mb-2 text-2xl font-bold text-text-primary">Create your account</h1>
          <p className="text-center text-sm text-text-secondary">Sign up with your USN to get started</p>
        </div>

        <form onSubmit={handleSignup} className="space-y-5">
          <div>
            <label htmlFor="signup-name" className="label">Full Name</label>
            <input id="signup-name" className="input" value={fullName} onChange={(e) => setFullName(e.target.value)} placeholder="e.g. Jane Doe" autoComplete="name" required />
          </div>
          <div>
            <label htmlFor="signup-usn" className="label">USN</label>
            <input id="signup-usn" className="input" value={usn} onChange={(e) => setUsn(e.target.value)} placeholder="e.g. 4MW21AI042" autoComplete="username" autoCapitalize="characters" required />
          </div>
          <div>
            <label htmlFor="signup-phone" className="label">Phone (optional)</label>
            <input id="signup-phone" type="tel" className="input" value={phone} onChange={(e) => setPhone(e.target.value)} placeholder="e.g. 9876543210" autoComplete="tel" />
          </div>
          <PasswordInput label="Password" value={password} onChange={setPassword} autoComplete="new-password" minLength={6} />
          <PasswordInput label="Confirm Password" value={confirmPassword} onChange={setConfirmPassword} autoComplete="new-password" minLength={6} />

          <label className="flex items-start gap-3 text-xs leading-relaxed text-text-secondary">
            <input type="checkbox" className="mt-0.5 h-4 w-4 accent-secondary" checked={agreed} onChange={(e) => setAgreed(e.target.checked)} />
            I understand that my name, USN, phone, socials and photo are collected for department use and may be visible to faculty and students. Contact the HOD office to request removal.
          </label>

          <ErrorText message={error} />

          <button type="submit" disabled={loading} className="btn-primary mt-2 w-full py-3">
            {loading ? "Creating account…" : "Sign Up"}
          </button>
        </form>

        <p className="mt-8 text-center text-sm text-text-secondary">
          Already have an account?{" "}
          <Link href="/login" className="font-bold text-secondary hover:underline">Login</Link>
        </p>
      </div>
    </div>
  );
}
