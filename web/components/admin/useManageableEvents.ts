"use client";

import { collection, limit, orderBy, query, where } from "firebase/firestore";
import { db } from "@/lib/firebase/firebase";
import { useLiveQuery } from "@/lib/hooks";
import { toEvent, type UserProfile } from "@/lib/models";

/** Events the caller can manage: the HOD sees all, coordinators only their own. */
export function useManageableEvents(profile: UserProfile | null) {
  return useLiveQuery(
    () => {
      if (!profile) return null;
      const events = collection(db, "events");
      return profile.role === "hod"
        ? query(events, orderBy("eventDate", "desc"), limit(100))
        : query(events, where("createdBy", "==", profile.uid), orderBy("eventDate", "desc"), limit(100));
    },
    toEvent,
    [profile?.uid, profile?.role],
  );
}
