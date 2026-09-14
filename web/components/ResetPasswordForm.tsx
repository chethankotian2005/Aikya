"use client";

import { useState } from "react";
import Image from "next/image";
import { updatePassword } from "firebase/auth";
import { doc, updateDoc } from "firebase/firestore";
import { auth, db } from "@/lib/firebase/firebase";
import { logout } from "@/lib/auth-context";
import { friendlyError } from "@/lib/errors";
import PasswordInput from "@/components/PasswordInput";
import { ErrorText } from "@/components/ui";

export default function ResetPasswordForm() {
  const [password, setPassword] = useState("");
  const [confirm, setConfirm] = useState("");
  const [error, setError] = useState("");
  const [saving, setSaving] = useState(false);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    if (password.length < 6) return setError("Password must be at least 6 characters.");
    if (password !== confirm) return setError("Passwords do not match.");

    const user = auth.currentUser;
    if (!user) return setError("Please sign in again.");

    setSaving(true);
    try {
      await updatePassword(user, password);
      await updateDoc(doc(db, "users", user.uid), { mustResetPassword: false });
      window.location.href = "/";
    } catch (err) {
      setError(friendlyError(err));
      setSaving(false);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-primary-surface p-4">
      <div className="card w-full max-w-md p-8">
        <div className="mb-6 flex flex-col items-center text-center">
          <Image src="/aikya_logo_cropped.png" alt="Aikya logo" width={120} height={60} className="mb-4 object-contain" />
          <h1 className="text-2xl font-bold text-text-primary">Change your password</h1>
          <p className="mt-2 text-sm text-text-secondary">
            For your security, choose a new password before you continue using AIKYA.
          </p>
        </div>
        <form onSubmit={submit} className="space-y-5">
          <PasswordInput label="New Password" value={password} onChange={setPassword} autoComplete="new-password" minLength={6} />
          <PasswordInput label="Confirm New Password" value={confirm} onChange={setConfirm} autoComplete="new-password" minLength={6} />
          <ErrorText message={error} />
          <button type="submit" disabled={saving} className="btn-primary w-full py-3">
            {saving ? "Updating…" : "Update password"}
          </button>
          <button type="button" onClick={logout} className="btn-outline w-full">
            Log out
          </button>
        </form>
      </div>
    </div>
  );
}
