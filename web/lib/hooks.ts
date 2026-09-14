"use client";

import { useEffect, useState, type DependencyList } from "react";
import { onSnapshot, type DocumentData, type DocumentReference, type Query } from "firebase/firestore";
import { friendlyError } from "@/lib/errors";

export interface Live<T> {
  data: T;
  loading: boolean;
  error: string;
}

/** Subscribes to a Firestore query; pass `null` from the factory to skip. */
export function useLiveQuery<T>(
  makeQuery: () => Query<DocumentData> | null,
  map: (id: string, data: DocumentData) => T,
  deps: DependencyList,
): Live<T[]> {
  const [state, setState] = useState<Live<T[]>>({ data: [], loading: true, error: "" });

  useEffect(() => {
    const q = makeQuery();
    if (!q) {
      setState({ data: [], loading: false, error: "" });
      return;
    }
    setState((s) => ({ ...s, loading: true }));
    return onSnapshot(
      q,
      (snap) => setState({ data: snap.docs.map((d) => map(d.id, d.data())), loading: false, error: "" }),
      (err) => setState({ data: [], loading: false, error: friendlyError(err) }),
    );
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, deps);

  return state;
}

/** Subscribes to a single document; `data` is null when it doesn't exist. */
export function useLiveDoc<T>(
  makeRef: () => DocumentReference<DocumentData> | null,
  map: (id: string, data: DocumentData) => T,
  deps: DependencyList,
): Live<T | null> {
  const [state, setState] = useState<Live<T | null>>({ data: null, loading: true, error: "" });

  useEffect(() => {
    const ref = makeRef();
    if (!ref) {
      setState({ data: null, loading: false, error: "" });
      return;
    }
    return onSnapshot(
      ref,
      (snap) => setState({ data: snap.exists() ? map(snap.id, snap.data()) : null, loading: false, error: "" }),
      (err) => setState({ data: null, loading: false, error: friendlyError(err) }),
    );
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, deps);

  return state;
}
