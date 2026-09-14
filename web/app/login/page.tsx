"use client";

import { useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { signInWithEmailAndPassword } from "firebase/auth";
import { auth } from "@/lib/firebase/firebase";
import { friendlyError } from "@/lib/errors";
import PasswordInput from "@/components/PasswordInput";
import { ErrorText } from "@/components/ui";

type LoginRole = "student" | "faculty";

const toEmail = (id: string, role: LoginRole) => {
  const sanitized = id.trim().toLowerCase().replace(/\s+/g, "");
  return role === "faculty" ? `${sanitized}@aikya.internal` : `${sanitized}@aikya.smvitm.edu`;
};

export default function LoginPage() {
  const [role, setRole] = useState<LoginRole>("student");
  const [idValue, setIdValue] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      const credential = await signInWithEmailAndPassword(auth, toEmail(idValue, role), password);
      const idToken = await credential.user.getIdToken();

      const res = await fetch("/api/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ idToken }),
      });
      if (!res.ok) {
        const data = await res.json().catch(() => ({}));
        throw new Error(data.error || "Could not start your session. Please try again.");
      }

      // Full navigation so the server layout routes to setup / password reset / home.
      window.location.href = "/";
    } catch (err) {
      setError(friendlyError(err));
      setLoading(false);
    }
  };

  const switchRole = (next: LoginRole) => {
    setRole(next);
    setIdValue("");
    setPassword("");
    setError("");
  };

  return (
    <div className="relative flex min-h-screen flex-col items-center justify-center overflow-hidden bg-primary-surface p-4">
      <div className="pointer-events-none absolute inset-0 bg-wave-motif" />

      <div className="card relative z-10 w-full max-w-md p-8">
        <div className="mb-6 flex flex-col items-center">
          <Image src="/aikya_logo_cropped.png" alt="Aikya logo" width={160} height={80} className="mb-4 object-contain" priority />
          <h1 className="mb-2 text-2xl font-bold text-text-primary">Welcome to AIKYA</h1>
          <p className="text-center text-sm text-text-secondary">
            {role === "student" ? "Login with your USN to continue" : "Login with your Faculty ID to continue"}
          </p>
        </div>

        <div role="tablist" aria-label="Account type" className="mb-8 flex rounded-full bg-primary-container p-1">
          {(["student", "faculty"] as const).map((r) => (
            <button
              key={r}
              type="button"
              role="tab"
              aria-selected={role === r}
              onClick={() => switchRole(r)}
              className={`flex-1 rounded-full py-2 text-sm font-medium transition-colors ${
                role === r ? "bg-surface-elevated text-text-primary shadow-sm" : "text-text-secondary hover:text-text-primary"
              }`}
            >
              {r === "student" ? "Student" : "Faculty"}
            </button>
          ))}
        </div>

        <form onSubmit={handleLogin} className="space-y-5">
          <div>
            <label htmlFor="login-id" className="label">
              {role === "student" ? "USN" : "Faculty ID"}
            </label>
            <input
              id="login-id"
              type="text"
              className="input"
              value={idValue}
              onChange={(e) => setIdValue(e.target.value)}
              placeholder={role === "student" ? "e.g. 4MW21AI042" : "e.g. 0544"}
              autoComplete="username"
              autoCapitalize={role === "student" ? "characters" : "none"}
              required
            />
          </div>
          <PasswordInput label="Password" value={password} onChange={setPassword} />

          <ErrorText message={error} />

          <button type="submit" disabled={loading} className="btn-primary mt-2 w-full py-3">
            {loading ? "Signing in…" : "Login"}
          </button>
        </form>

        {role === "student" && (
          <p className="mt-8 text-center text-sm text-text-secondary">
            New User?{" "}
            <Link href="/signup" className="font-bold text-secondary hover:underline">
              Sign Up
            </Link>
          </p>
        )}
      </div>
    </div>
  );
}
