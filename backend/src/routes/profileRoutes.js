/**
 * PUT /api/profile — any signed-in user updates their own profile.
 *
 * Students: USN must match the account's USN (derived from the Auth email);
 * batch/year are resolved from academicBatchConfig. Staff have no USN.
 * Optional fields are only written when present in the body, so a partial
 * edit never wipes existing values.
 */

import express from 'express';
import admin from 'firebase-admin';
import parseUsn from '../utils/usnParser.js';
import { verifyAuth } from '../middleware/verifyAuth.js';

const router = express.Router();

// Must match the 12 entries in each client's avatar catalog (lib/avatars.ts /
// widgets/avatar_picker.dart). A profile shows the avatar when avatarId is
// set, otherwise falls back to profilePictureUrl (a Cloudinary secure_url
// from POST /api/upload-image) — the client sends whichever one it cleared
// as null when the user switches between the two options.
const AVATAR_COUNT = 12;

const OPTIONAL_STRING_FIELDS = [
  'phone',
  'bio',
  'githubUrl',
  'linkedinUrl',
  'instagramHandle',
  'personalWebsite',
  'twitterHandle',
  'discordHandle',
  'profilePictureUrl',
];

function optionalString(value) {
  if (value === undefined) return undefined;
  if (typeof value !== 'string') return null;
  const trimmed = value.trim();
  return trimmed ? trimmed.slice(0, 500) : null;
}

router.put('/profile', verifyAuth, async (req, res) => {
  try {
    const { fullName, usn, skills, avatarId, flagForHodReview, privacySettings, notificationSettings } = req.body;

    if (typeof fullName !== 'string' || !fullName.trim()) {
      return res.status(400).json({ error: 'Full name is required.' });
    }
    if (avatarId !== undefined && avatarId !== null) {
      if (!Number.isInteger(avatarId) || avatarId < 1 || avatarId > AVATAR_COUNT) {
        return res.status(400).json({ error: 'Invalid avatar selection.' });
      }
    }

    const db = admin.firestore();
    const userRef = db.collection('users').doc(req.uid);
    const existing = (await userRef.get()).data() || {};

    // fullName is only settable during first-run setup — the UI shows it as
    // locked everywhere else, and this enforces that server-side too (a
    // valid session could otherwise rename the account via a direct API call).
    const updateData = {
      fullName: existing.profileComplete === true ? existing.fullName : fullName.trim().slice(0, 100),
      profileComplete: true,
    };

    if (avatarId !== undefined) {
      updateData.avatarId = avatarId;
    }

    for (const field of OPTIONAL_STRING_FIELDS) {
      const value = optionalString(req.body[field]);
      if (value !== undefined) updateData[field] = value;
    }

    if (Array.isArray(skills)) {
      updateData.skills = skills
        .filter((s) => typeof s === 'string' && s.trim())
        .map((s) => s.trim().slice(0, 40))
        .slice(0, 20);
    }

    if (privacySettings && typeof privacySettings === 'object') {
      updateData.privacySettings = privacySettings;
    }

    if (notificationSettings && typeof notificationSettings === 'object') {
      updateData.notificationSettings = notificationSettings;
    }

    if (flagForHodReview === true) {
      updateData.flagForHodReview = true;
    }

    if (req.role === 'student') {
      const accountUsn = req.email?.split('@')[0]?.toUpperCase();
      const parsedUsn = parseUsn(usn ?? accountUsn);

      if (!parsedUsn) {
        return res.status(400).json({ error: 'Invalid USN format. Expected e.g. 4MW21AI042.' });
      }
      if (parsedUsn.usn !== accountUsn) {
        return res.status(400).json({ error: 'USN does not match your account.' });
      }

      const configDoc = await db.collection('academicBatchConfig').doc(parsedUsn.configKey).get();
      updateData.usn = parsedUsn.usn;

      if (configDoc.exists) {
        const config = configDoc.data();
        updateData.yearOfStudy = config.yearOfStudy?.toString() ?? null;
        updateData.batch = config.label ?? null;
        updateData.status = null;
      } else {
        updateData.yearOfStudy = null;
        updateData.batch = null;
        updateData.status = 'pending_batch_review';
      }
    }

    await db.collection('users').doc(req.uid).set(updateData, { merge: true });

    return res.json({ success: true, user: updateData });
  } catch (error) {
    console.error('Error updating profile:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
