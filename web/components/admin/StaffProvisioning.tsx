"use client";

import { useState } from "react";
import { collection, query, where } from "firebase/firestore";
import { db } from "@/lib/firebase/firebase";
import { callBackend } from "@/lib/api";
import { friendlyError } from "@/lib/errors";
import { useLiveQuery } from "@/lib/hooks";
import { CLUBS, ROLE_LABELS, toProfile } from "@/lib/models";
import { ErrorText, PageSpinner, TagChip } from "@/components/ui";

type ProvisionResult = { results: { facultyId: string; status: string }[]; errors: { facultyId: string; error: string }[] };

/** HOD-only Staff Provisioning — POST /api/admin/provision-staff. */
export default function StaffProvisioning() {
  const staff = useLiveQuery(
    () => query(collection(db, "users"), where("role", "in", ["faculty", "coordinator", "hod"])),
    toProfile,
    [],
  );
  const [facultyId, setFacultyId] = useState("");
  const [fullName, setFullName] = useState("");
  const [designation, setDesignation] = useState("");
  const [role, setRole] = useState<"faculty" | "coordinator">("faculty");
  const [club, setClub] = useState("");
  const [error, setError] = useState("");
  const [notice, setNotice] = useState("");
  const [saving, setSaving] = useState(false);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setNotice("");
    const id = facultyId.trim();
    if (!/^[A-Za-z0-9]{3,20}$/.test(id)) return setError("Faculty ID must be 3–20 letters or digits.");
    if (!fullName.trim()) return setError("Full name is required.");
    if (role === "coordinator" && !club) return setError("Coordinators need a club.");

    setSaving(true);
    try {
      const res = await callBackend<ProvisionResult>("admin/provision-staff", {
        staff: [{ facultyId: id, fullName: fullName.trim(), designation: designation.trim(), role, ...(role === "coordinator" ? { club } : {}) }],
      });
      if (res.errors.length) {
        setError(res.errors[0].error);
      } else {
        setNotice(`Account ready. Faculty ID ${id}, first password ${id}@ml (they must change it on first login).`);
        setFacultyId("");
        setFullName("");
        setDesignation("");
        setClub("");
      }
    } catch (err) {
      setError(friendlyError(err));
    } finally {
      setSaving(false);
    }
  };

  const sorted = [...staff.data].sort((a, b) => a.fullName.localeCompare(b.fullName));

  return (
    <div className="flex flex-col gap-5 p-5">
      <p className="text-sm text-text-secondary">
        New faculty and coordinators log in with their Faculty ID. The first password is <code>{"{FacultyID}"}@ml</code> and must be changed on first login.
      </p>
      <form onSubmit={submit} className="card grid gap-4 p-4 sm:grid-cols-2">
        <div>
          <label htmlFor="s-id" className="label">Faculty ID</label>
          <input id="s-id" className="input" value={facultyId} onChange={(e) => setFacultyId(e.target.value)} placeholder="e.g. 0544" />
        </div>
        <div>
          <label htmlFor="s-name" className="label">Full name</label>
          <input id="s-name" className="input" value={fullName} onChange={(e) => setFullName(e.target.value)} />
        </div>
        <div>
          <label htmlFor="s-desig" className="label">Designation (optional)</label>
          <input id="s-desig" className="input" value={designation} onChange={(e) => setDesignation(e.target.value)} />
        </div>
        <div>
          <label htmlFor="s-role" className="label">Role</label>
          <select id="s-role" className="input" value={role} onChange={(e) => setRole(e.target.value as "faculty" | "coordinator")}>
            <option value="faculty">Faculty</option>
            <option value="coordinator">Coordinator</option>
          </select>
        </div>
        {role === "coordinator" && (
          <div>
            <label htmlFor="s-club" className="label">Club</label>
            <select id="s-club" className="input" value={club} onChange={(e) => setClub(e.target.value)}>
              <option value="">Choose a club</option>
              {CLUBS.map((c) => <option key={c}>{c}</option>)}
            </select>
          </div>
        )}
        <div className="sm:col-span-2">
          <ErrorText message={error} />
          {notice && <p role="status" className="text-sm font-semibold text-success">{notice}</p>}
          <button type="submit" className="btn-primary mt-2 w-full" disabled={saving}>
            {saving ? "Creating…" : "Create account"}
          </button>
        </div>
      </form>

      <section>
        <h3 className="mb-3 font-bold text-text-primary">Current staff</h3>
        {staff.loading ? (
          <PageSpinner />
        ) : (
          <ul className="flex flex-col gap-2">
            {sorted.map((s) => (
              <li key={s.uid} className="card flex items-center gap-3 p-4">
                <div className="flex-1">
                  <p className="text-sm font-semibold text-text-primary">{s.fullName}</p>
                  <p className="text-xs text-text-tertiary">
                    {[ROLE_LABELS[s.role], s.club, s.facultyId && `ID ${s.facultyId}`].filter(Boolean).join(" · ")}
                  </p>
                </div>
                {s.mustResetPassword && <TagChip label="Awaiting first login" tone="warning" />}
              </li>
            ))}
          </ul>
        )}
      </section>
    </div>
  );
}
