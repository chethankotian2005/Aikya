"use client";

import { useState } from "react";
import { collection, deleteDoc, doc, setDoc, updateDoc } from "firebase/firestore";
import { Trash2 } from "lucide-react";
import { db } from "@/lib/firebase/firebase";
import { friendlyError } from "@/lib/errors";
import { useLiveQuery } from "@/lib/hooks";
import { ErrorText, PageSpinner } from "@/components/ui";

type Row = { id: string; yearOfStudy: number; label: string; graduated: boolean };

/** HOD-maintained USN batch → year lookup (key = "{admissionYY}_{entryType}", spec §4). */
export default function BatchConfig() {
  const rows = useLiveQuery(
    () => collection(db, "academicBatchConfig"),
    (id, d): Row => ({
      id,
      yearOfStudy: typeof d.yearOfStudy === "number" ? d.yearOfStudy : 1,
      label: typeof d.label === "string" ? d.label : "",
      graduated: d.graduated === true,
    }),
    [],
  );
  const [yy, setYy] = useState("");
  const [entryType, setEntryType] = useState("regular");
  const [year, setYear] = useState(1);
  const [label, setLabel] = useState("");
  const [error, setError] = useState("");

  const run = (action: Promise<unknown>) => action.catch((err) => setError(friendlyError(err)));

  const add = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    if (!/^\d{2}$/.test(yy)) return setError("Admission year must be two digits, e.g. 24.");
    await run(setDoc(doc(db, "academicBatchConfig", `${yy}_${entryType}`), { yearOfStudy: year, label: label.trim() || `${year} Year`, graduated: false }));
    setYy("");
    setLabel("");
  };

  return (
    <div className="flex flex-col gap-5 p-5">
      <p className="text-sm text-text-secondary">Maps each admission batch to its current year. Update it every academic year.</p>
      <form onSubmit={add} className="card grid gap-3 p-4 sm:grid-cols-5 sm:items-end">
        <div>
          <label htmlFor="b-yy" className="label">Admission YY</label>
          <input id="b-yy" className="input" value={yy} onChange={(e) => setYy(e.target.value)} placeholder="24" />
        </div>
        <div>
          <label htmlFor="b-entry" className="label">Entry type</label>
          <select id="b-entry" className="input" value={entryType} onChange={(e) => setEntryType(e.target.value)}>
            <option value="regular">Regular</option>
            <option value="lateral_diploma">Lateral (diploma)</option>
          </select>
        </div>
        <div>
          <label htmlFor="b-year" className="label">Year of study</label>
          <select id="b-year" className="input" value={year} onChange={(e) => setYear(Number(e.target.value))}>
            {[1, 2, 3, 4].map((y) => <option key={y} value={y}>{y}</option>)}
          </select>
        </div>
        <div>
          <label htmlFor="b-label" className="label">Label</label>
          <input id="b-label" className="input" value={label} onChange={(e) => setLabel(e.target.value)} placeholder="3rd Year" />
        </div>
        <button type="submit" className="btn-primary">Add row</button>
      </form>
      <ErrorText message={error || rows.error} />

      {rows.loading ? (
        <PageSpinner />
      ) : (
        <div className="card overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="border-b border-border text-xs text-text-tertiary">
              <tr>
                <th className="p-3">Batch key</th><th className="p-3">Year</th><th className="p-3">Label</th><th className="p-3">Graduated</th><th className="p-3" />
              </tr>
            </thead>
            <tbody>
              {rows.data.map((r) => (
                <tr key={r.id} className="border-b border-border last:border-0">
                  <td className="p-3 font-semibold text-text-primary">{r.id}</td>
                  <td className="p-3">
                    <select aria-label={`Year for ${r.id}`} className="input w-20" value={r.yearOfStudy} onChange={(e) => run(updateDoc(doc(db, "academicBatchConfig", r.id), { yearOfStudy: Number(e.target.value) }))}>
                      {[1, 2, 3, 4].map((y) => <option key={y} value={y}>{y}</option>)}
                    </select>
                  </td>
                  <td className="p-3">
                    <input
                      aria-label={`Label for ${r.id}`}
                      className="input"
                      defaultValue={r.label}
                      onBlur={(e) => e.target.value !== r.label && run(updateDoc(doc(db, "academicBatchConfig", r.id), { label: e.target.value.trim() }))}
                    />
                  </td>
                  <td className="p-3">
                    <input type="checkbox" aria-label={`${r.id} graduated`} className="h-4 w-4 accent-secondary" checked={r.graduated} onChange={(e) => run(updateDoc(doc(db, "academicBatchConfig", r.id), { graduated: e.target.checked }))} />
                  </td>
                  <td className="p-3">
                    <button type="button" aria-label={`Delete ${r.id}`} className="text-text-tertiary hover:text-error" onClick={() => confirm(`Delete ${r.id}?`) && run(deleteDoc(doc(db, "academicBatchConfig", r.id)))}>
                      <Trash2 size={16} />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
