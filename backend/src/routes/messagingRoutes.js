/**
 * Privileged writes that also send a push notification in the same request
 * (spec §2/§7 — avoids Cloud Functions).
 *
 *   POST /api/messaging/updates                  faculty, coordinator, hod
 *   POST /api/messaging/attendance/approve       hod
 *   POST /api/messaging/attendance/reject        hod
 *   POST /api/messaging/memory-frame/approve     hod
 *   POST /api/messaging/memory-frame/reject      hod
 *
 * Author, reviewer and timestamps are always taken from the verified
 * caller — never from the request body.
 */

import express from 'express';
import admin from 'firebase-admin';
import { verifyAuth, requireRole } from '../middleware/verifyAuth.js';

const router = express.Router();
const db = () => admin.firestore();
const { FieldValue, Timestamp } = admin.firestore;

const ROLE_LABELS = { faculty: 'Faculty', coordinator: 'Coordinator', hod: 'HOD' };
const MAX_UPDATE_LENGTH = 2000;

/** Push failures are logged, never surfaced — the write itself already succeeded. */
async function sendNotification(message) {
  try {
    await admin.messaging().send(message);
  } catch (error) {
    console.error('Error sending FCM message:', error.code || error.message);
  }
}

async function notifyUser(uid, settingKey, notification, data) {
  const snap = await db().collection('users').doc(uid).get();
  if (!snap.exists) return;

  const { fcmToken, notificationSettings } = snap.data();
  if (!fcmToken || notificationSettings?.[settingKey] === false) return;

  await sendNotification({ notification, token: fcmToken, data });
}

router.post(
  '/updates',
  verifyAuth,
  requireRole('faculty', 'coordinator', 'hod'),
  async (req, res) => {
    try {
      const { content, deadlineDate, imageUrl } = req.body;

      if (typeof content !== 'string' || !content.trim()) {
        return res.status(400).json({ error: 'Update text is required.' });
      }
      if (content.length > MAX_UPDATE_LENGTH) {
        return res.status(400).json({ error: `Updates are limited to ${MAX_UPDATE_LENGTH} characters.` });
      }

      let deadline = null;
      if (deadlineDate) {
        const parsed = new Date(deadlineDate);
        if (Number.isNaN(parsed.getTime())) {
          return res.status(400).json({ error: 'Invalid deadline date.' });
        }
        deadline = Timestamp.fromDate(parsed);
      }

      const ref = db().collection('updates').doc();
      const updateDoc = {
        id: ref.id,
        content: content.trim(),
        deadlineDate: deadline,
        imageUrl: typeof imageUrl === 'string' && imageUrl ? imageUrl : null,
        authorId: req.uid,
        authorName: req.userName || 'Department',
        authorDesignation: req.designation || ROLE_LABELS[req.role],
        club: req.club,
        createdAt: FieldValue.serverTimestamp(),
      };

      await ref.set(updateDoc);

      const body = updateDoc.content;
      await sendNotification({
        notification: {
          title: `New update from ${updateDoc.authorName}`,
          body: body.length > 80 ? `${body.substring(0, 80)}…` : body,
        },
        topic: 'all_students',
        data: { type: 'update', id: ref.id },
      });

      res.status(200).json({ success: true, id: ref.id });
    } catch (error) {
      console.error('Error posting update:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  },
);

/**
 * Shared pending → approved/rejected review for attendance requests and memory frames.
 */
function reviewRoute({ collection, ownerField, settingKey, status, notificationFor }) {
  return async (req, res) => {
    try {
      const id = req.body.requestId ?? req.body.memoryId;
      const note = typeof req.body.note === 'string' ? req.body.note.trim().slice(0, 500) : '';

      if (!id || typeof id !== 'string') {
        return res.status(400).json({ error: 'A document ID is required.' });
      }

      const ref = db().collection(collection).doc(id);
      const snap = await ref.get();
      if (!snap.exists) {
        return res.status(404).json({ error: 'Not found.' });
      }

      const item = snap.data();
      if (item.status !== 'pending') {
        return res.status(409).json({ error: `Already ${item.status}.` });
      }

      await ref.update({
        status,
        reviewedBy: req.uid,
        reviewedAt: FieldValue.serverTimestamp(),
        reviewNotes: note,
      });

      let eventTitle = 'the event';
      if (item.eventId) {
        const eventSnap = await db().collection('events').doc(item.eventId).get();
        if (eventSnap.exists) eventTitle = eventSnap.data().title;
      }

      const { notification, data } = notificationFor({ id, item, eventTitle, note });
      await notifyUser(item[ownerField], settingKey, notification, data);

      res.status(200).json({ success: true, status });
    } catch (error) {
      console.error(`Error reviewing ${collection}:`, error);
      res.status(500).json({ error: 'Internal server error' });
    }
  };
}

const attendanceNotification = (status) => ({ item, eventTitle, note }) => ({
  notification: {
    title: status === 'approved' ? 'Attendance Approved ✅' : 'Attendance Rejected ❌',
    body:
      status === 'approved'
        ? `Your attendance for "${eventTitle}" has been approved.`
        : `Your attendance for "${eventTitle}" was rejected.${note ? ` Note: ${note}` : ''}`,
  },
  data: { type: 'attendance', eventId: item.eventId || '' },
});

const memoryNotification = (status) => ({ id, eventTitle, note }) => ({
  notification: {
    title: status === 'approved' ? 'Memory Approved \u{1F4F8}' : 'Memory Not Approved',
    body:
      status === 'approved'
        ? `Your photo for "${eventTitle}" is now live on the Memory Wall!`
        : `Your photo for "${eventTitle}" wasn't approved.${note ? ` Note: ${note}` : ''}`,
  },
  data: { type: 'memory_frame', memoryId: id },
});

for (const status of ['approved', 'rejected']) {
  const action = status === 'approved' ? 'approve' : 'reject';

  router.post(
    `/attendance/${action}`,
    verifyAuth,
    requireRole('hod'),
    reviewRoute({
      collection: 'attendanceRequests',
      ownerField: 'studentId',
      settingKey: 'eventsEnabled',
      status,
      notificationFor: attendanceNotification(status),
    }),
  );

  router.post(
    `/memory-frame/${action}`,
    verifyAuth,
    requireRole('hod'),
    reviewRoute({
      collection: 'memoryFrames',
      ownerField: 'uploadedBy',
      settingKey: 'memoriesEnabled',
      status,
      notificationFor: memoryNotification(status),
    }),
  );
}

export default router;
