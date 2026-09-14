"use client";

import { createContext, useContext, useEffect, useState, type ReactNode } from "react";
import { onAuthStateChanged, signOut, type User } from "firebase/auth";
import { doc, onSnapshot } from "firebase/firestore";
import { auth, db } from "@/lib/firebase/firebase";
import { toProfile, type UserProfile } from "@/lib/models";

interface AuthState {
  user: User | null;
  profile: UserProfile | null;
  loading: boolean;
}

const AuthContext = createContext<AuthState>({ user: null, profile: null, loading: true });

/** Clears both the Firebase client session and the server session cookie. */
export async function logout() {
  await signOut(auth).catch(() => {});
  await fetch("/api/logout", { method: "POST" }).catch(() => {});
  window.location.href = "/login";
}

/**
 * Live Firebase user + their users/{uid} profile. Pages under the (app) and
 * (admin) layouts are only rendered for a verified server session, so a
 * missing client user means the two sessions drifted — sign out cleanly.
 */
export function AuthProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<AuthState>({ user: null, profile: null, loading: true });

  useEffect(() => {
    let unsubscribeProfile: (() => void) | undefined;

    const unsubscribeAuth = onAuthStateChanged(auth, (user) => {
      unsubscribeProfile?.();
      if (!user) {
        setState({ user: null, profile: null, loading: false });
        logout();
        return;
      }
      unsubscribeProfile = onSnapshot(
        doc(db, "users", user.uid),
        (snap) =>
          setState({
            user,
            profile: snap.exists() ? toProfile(snap.id, snap.data()) : null,
            loading: false,
          }),
        () => setState({ user, profile: null, loading: false }),
      );
    });

    return () => {
      unsubscribeProfile?.();
      unsubscribeAuth();
    };
  }, []);

  return <AuthContext.Provider value={state}>{children}</AuthContext.Provider>;
}

export const useAuth = () => useContext(AuthContext);
