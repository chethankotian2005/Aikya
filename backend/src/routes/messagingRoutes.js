/**
 * Privileged writes that also send a push notification in the same request
 * (spec §2/§7 — avoids Cloud Functions).
 *
 *   POST /api/messaging/updates                  faculty, coordinator, hod
 *   POST /api/messaging/events                   coordinator, hod
 *   POST /api/messaging/attendance/approve       hod
 *   POST /api/messaging/attendance/reject        hod
 *   POST /api/messaging/memory-frame/approve     hod
 *   POST /api/messaging/memory-frame/reject      hod
 *   POST /api/messaging/event/approve            hod
 *   POST /api/messaging/event/reject             hod
 *
 * Author, reviewer and timestamps are always taken from the verified
 * caller — never from the request body.
 *
 * Events created by a coordinator start as `status: 'pending'` and are
 * invisible to everyone but their creator and the HOD until an HOD approves
 * them (an HOD's own events are auto-approved — they're already the
 * approver). This is why event creation goes through the backend at all
 * instead of a direct client Firestore write like most collections.
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

async function notifyHods(settingKey, notification, data) {
  const snap = await db().collection('users').where('role', '==', 'hod').get();
  await Promise.all(snap.docs.map((doc) => notifyUser(doc.id, settingKey, notification, data)));
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

router.post(
  '/events',
  verifyAuth,
  requireRole('coordinator', 'hod'),
  async (req, res) => {
    try {
      const {
        title, description, venue, eventDate, endDate, maxCapacity,
        registrationDeadline, formFields, tag, club, bannerUrl,
      } = req.body;

      if (typeof title !== 'string' || title.trim().length < 3 || title.length > 120) {
        return res.status(400).json({ error: 'Title must be 3-120 characters.' });
      }
      if (typeof description !== 'string' || !description.trim()) {
        return res.status(400).json({ error: 'Description is required.' });
      }
      if (typeof venue !== 'string' || !venue.trim()) {
        return res.status(400).json({ error: 'Venue is required.' });
      }
      const parsedEventDate = new Date(eventDate);
      if (Number.isNaN(parsedEventDate.getTime())) {
        return res.status(400).json({ error: 'A valid eventDate is required.' });
      }
      let parsedEndDate = null;
      if (endDate) {
        parsedEndDate = new Date(endDate);
        if (Number.isNaN(parsedEndDate.getTime())) {
          return res.status(400).json({ error: 'Invalid endDate.' });
        }
      }
      if (!Number.isInteger(maxCapacity) || maxCapacity < 1) {
        return res.status(400).json({ error: 'maxCapacity must be a positive integer.' });
      }
      const parsedDeadline = new Date(registrationDeadline);
      if (Number.isNaN(parsedDeadline.getTime())) {
        return res.status(400).json({ error: 'A valid registrationDeadline is required.' });
      }

      const status = req.role === 'hod' ? 'approved' : 'pending';

      const eventDoc = {
        title: title.trim(),
        description: description.trim(),
        venue: venue.trim(),
        eventDate: Timestamp.fromDate(parsedEventDate),
        endDate: parsedEndDate ? Timestamp.fromDate(parsedEndDate) : null,
        maxCapacity,
        currentRegistrations: 0,
        registrationDeadline: Timestamp.fromDate(parsedDeadline),
        customFormSchema: { fields: Array.isArray(formFields) ? formFields : [] },
        tag: typeof tag === 'string' && tag ? tag : 'General',
        club: req.role === 'coordinator' ? req.club : (typeof club === 'string' && club ? club : null),
        bannerUrl: typeof bannerUrl === 'string' && bannerUrl ? bannerUrl : null,
        status,
        createdBy: req.uid,
        createdAt: FieldValue.serverTimestamp(),
      };

      const ref = await db().collection('events').add(eventDoc);

      if (status === 'pending') {
        await notifyHods('eventsEnabled', {
          title: 'Event awaiting approval',
          body: `${req.userName || 'A coordinator'} submitted "${eventDoc.title}" for review.`,
        }, { type: 'event_review', eventId: ref.id });
      } else {
        // An HOD's own event is auto-approved, so it goes live immediately —
        // students hear about it in the same request.
        await sendNotification({
          notification: {
            title: `New event: ${eventDoc.title}`,
            body: `${eventDoc.venue} — tap to see details and register.`,
          },
          topic: 'all_students',
          data: { type: 'event_published', eventId: ref.id },
        });
      }

      res.status(200).json({ success: true, id: ref.id, status });
    } catch (error) {
      console.error('Error creating event:', error);
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
      const id = req.body.requestId ?? req.body.memoryId ?? req.body.eventId;
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

      const { notification, data, broadcast } = notificationFor({ id, item, eventTitle, note });
      await notifyUser(item[ownerField], settingKey, notification, data);
      if (broadcast) await sendNotification({ notification: broadcast.notification, topic: broadcast.topic, data: broadcast.data ?? data });

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

const eventNotification = (status) => ({ id, item, note }) => ({
  notification: {
    title: status === 'approved' ? 'Event Approved ✅' : 'Event Rejected',
    body:
      status === 'approved'
        ? `Your event "${item.title}" is now live.`
        : `Your event "${item.title}" was rejected.${note ? ` Note: ${note}` : ''}`,
  },
  data: { type: 'event_review', eventId: id },
  // Approving a pending event is the moment it actually goes live for
  // students, so that's also when they hear about it — same as an HOD's
  // own event, which broadcasts immediately on creation (see POST /events).
  broadcast: status === 'approved' ? {
    topic: 'all_students',
    notification: { title: `New event: ${item.title}`, body: `${item.venue} — tap to see details and register.` },
    data: { type: 'event_published', eventId: id },
  } : undefined,
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
    `/event/${action}`,
    verifyAuth,
    requireRole('hod'),
    reviewRoute({
      collection: 'events',
      ownerField: 'createdBy',
      settingKey: 'eventsEnabled',
      status,
      notificationFor: eventNotification(status),
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
