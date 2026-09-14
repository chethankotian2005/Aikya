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
    const { fullName, usn, skills, flagForHodReview, privacySettings, notificationSettings } = req.body;

    if (typeof fullName !== 'string' || !fullName.trim()) {
      return res.status(400).json({ error: 'Full name is required.' });
    }

    const updateData = {
      fullName: fullName.trim().slice(0, 100),
      profileComplete: true,
    };

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

    const db = admin.firestore();

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
