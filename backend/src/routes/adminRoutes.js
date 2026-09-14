/**
 * POST /api/admin/provision-staff — HOD only.
 *
 * Body: { staff: [ { facultyId, fullName, designation?, role: 'faculty'|'coordinator', club? } ] }
 *
 * Creates `{facultyId}@aikya.internal` Auth accounts with the default password
 * `{facultyId}@ml` and `mustResetPassword: true`, plus the users/{uid} doc.
 * Existing staff accounts are updated in place (password untouched).
 */

import express from 'express';
import admin from 'firebase-admin';
import { verifyAuth, requireRole } from '../middleware/verifyAuth.js';

const router = express.Router();

export const CLUBS = ['Aikya', 'IEEE', 'ISTE', 'Co-curricular', 'Extra-curricular'];
const STAFF_ROLES = ['faculty', 'coordinator'];
const MAX_BATCH = 100;

function validate(person) {
  const facultyId = typeof person?.facultyId === 'string' ? person.facultyId.trim() : '';
  const fullName = typeof person?.fullName === 'string' ? person.fullName.trim() : '';
  const { role, club } = person || {};

  if (!/^[A-Za-z0-9]{3,20}$/.test(facultyId)) {
    return { error: 'Faculty ID must be 3–20 letters or digits.' };
  }
  if (!fullName) return { error: 'Full name is required.' };
  if (!STAFF_ROLES.includes(role)) return { error: 'Role must be faculty or coordinator.' };
  if (role === 'coordinator' && !CLUBS.includes(club)) {
    return { error: `Coordinators need a club: ${CLUBS.join(', ')}.` };
  }

  return {
    facultyId,
    fullName,
    role,
    club: role === 'coordinator' ? club : null,
    designation: typeof person.designation === 'string' ? person.designation.trim() : '',
  };
}

router.post('/provision-staff', verifyAuth, requireRole('hod'), async (req, res) => {
  const { staff } = req.body;

  if (!Array.isArray(staff) || staff.length === 0 || staff.length > MAX_BATCH) {
    return res.status(400).json({ error: `Expected a "staff" array of 1–${MAX_BATCH} entries.` });
  }

  const db = admin.firestore();
  const results = [];
  const errors = [];

  for (const person of staff) {
    const entry = validate(person);
    if (entry.error) {
      errors.push({ facultyId: person?.facultyId ?? null, error: entry.error });
      continue;
    }

    const { facultyId, fullName, role, club, designation } = entry;

    try {
      const email = `${facultyId.toLowerCase()}@aikya.internal`;

      let userRecord;
      let created = false;
      try {
        userRecord = await admin.auth().createUser({
          email,
          password: `${facultyId}@ml`,
          displayName: fullName,
        });
        created = true;
      } catch (authError) {
        if (authError.code !== 'auth/email-already-exists') throw authError;
        userRecord = await admin.auth().getUserByEmail(email);
      }

      const userRef = db.collection('users').doc(userRecord.uid);
      const existing = await userRef.get();
      if (existing.exists && !STAFF_ROLES.includes(existing.data().role)) {
        errors.push({ facultyId, error: `Account exists with role "${existing.data().role}"; not changed.` });
        continue;
      }

      const userDoc = {
        uid: userRecord.uid,
        email,
        facultyId,
        fullName,
        role,
        club,
        designation: designation || null,
        profileComplete: true,
      };
      if (created || !existing.exists) {
        userDoc.mustResetPassword = true;
        userDoc.createdAt = admin.firestore.FieldValue.serverTimestamp();
      }

      await userRef.set(userDoc, { merge: true });
      results.push({ facultyId, status: created ? 'created' : 'updated' });
    } catch (err) {
      console.error(`Error provisioning ${facultyId}:`, err);
      errors.push({ facultyId, error: err.message });
    }
  }

  res.status(200).json({
    message: 'Provisioning complete',
    results,
    errors,
  });
});

export default router;
