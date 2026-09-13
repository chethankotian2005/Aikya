import express from 'express';
import admin from 'firebase-admin';
import { verifyToken, requireRole } from '../middleware/auth.js';

const router = express.Router();

/**
 * Helper to send FCM notifications silently failing if no token/topic exists.
 */
const sendNotification = async (message) => {
  try {
    const response = await admin.messaging().send(message);
    console.log('Successfully sent message:', response);
  } catch (error) {
    console.error('Error sending FCM message:', error);
  }
};

/**
 * POST /api/messaging/updates
 * Creates an update doc in Firestore and sends FCM to all_students topic.
 */
router.post('/updates', verifyToken, requireRole(['faculty', 'coordinator', 'hod']), async (req, res) => {
  try {
    const { id, content, deadlineDate, authorId, authorName, authorDesignation, club, createdAt } = req.body;

    const updateDoc = {
      id,
      content,
      deadlineDate: deadlineDate || null,
      authorId,
      authorName,
      authorDesignation,
      club: club || null,
      createdAt: createdAt ? new Date(createdAt) : admin.firestore.FieldValue.serverTimestamp(),
    };

    // 1. Write to Firestore
    await admin.firestore().collection('updates').doc(id).set(updateDoc);

    // 2. Send FCM to all_students topic
    const message = {
      notification: {
        title: `New Update from ${authorName}`,
        body: content.length > 50 ? `${content.substring(0, 50)}...` : content,
      },
      topic: 'all_students',
      data: {
        type: 'update',
        id: id,
      },
    };
    await sendNotification(message);

    res.status(200).json({ success: true, message: 'Update posted and notification sent.' });
  } catch (error) {
    console.error('Error posting update:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * POST /api/messaging/attendance/approve
 * Approves attendance request and sends FCM to the specific student.
 */
router.post('/attendance/approve', verifyToken, requireRole(['coordinator', 'faculty', 'hod', 'admin']), async (req, res) => {
  try {
    const { requestId, eventId, studentId, eventTitle } = req.body;

    // 1. Update Firestore
    await admin.firestore()
      .collection('events')
      .doc(eventId)
      .collection('attendanceRequests')
      .doc(requestId)
      .update({
        status: 'approved',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    // 2. Get student FCM token (assume it's stored in user document)
    const userDoc = await admin.firestore().collection('users').doc(studentId).get();
    if (userDoc.exists) {
      const fcmToken = userDoc.data().fcmToken;
      const settings = userDoc.data().notificationSettings;
      
      // Check if student has muted event notifications
      const eventsMuted = settings && settings.eventsEnabled === false;
      
      if (fcmToken && !eventsMuted) {
        const message = {
          notification: {
            title: 'Attendance Approved \u2705', // Check mark emoji
            body: `Your attendance for "${eventTitle}" has been approved.`,
          },
          token: fcmToken,
          data: {
            type: 'attendance',
            eventId: eventId,
          },
        };
        await sendNotification(message);
      }
    }

    res.status(200).json({ success: true, message: 'Attendance approved.' });
  } catch (error) {
    console.error('Error approving attendance:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * POST /api/messaging/attendance/reject
 * Rejects attendance request and sends FCM to the specific student.
 */
router.post('/attendance/reject', verifyToken, requireRole(['coordinator', 'faculty', 'hod', 'admin']), async (req, res) => {
  try {
    const { requestId, eventId, studentId, eventTitle, note } = req.body;

    // 1. Update Firestore
    await admin.firestore()
      .collection('events')
      .doc(eventId)
      .collection('attendanceRequests')
      .doc(requestId)
      .update({
        status: 'rejected',
        reviewNotes: note || '',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    // 2. Get student FCM token
    const userDoc = await admin.firestore().collection('users').doc(studentId).get();
    if (userDoc.exists) {
      const fcmToken = userDoc.data().fcmToken;
      const settings = userDoc.data().notificationSettings;
      
      const eventsMuted = settings && settings.eventsEnabled === false;

      if (fcmToken && !eventsMuted) {
        const message = {
          notification: {
            title: 'Attendance Rejected \u274C', // Cross mark emoji
            body: `Your attendance for "${eventTitle}" was rejected. ${note ? 'Note: ' + note : ''}`,
          },
          token: fcmToken,
          data: {
            type: 'attendance',
            eventId: eventId,
          },
        };
        await sendNotification(message);
      }
    }

    res.status(200).json({ success: true, message: 'Attendance rejected.' });
  } catch (error) {
    console.error('Error rejecting attendance:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * POST /api/messaging/memory-frame/approve
 * Approves a memory frame upload and sends FCM to the student.
 */
router.post('/memory-frame/approve', verifyToken, requireRole(['coordinator', 'faculty', 'hod', 'admin']), async (req, res) => {
  try {
    const { memoryId, studentId, eventTitle } = req.body;

    // 1. Update Firestore
    // Assuming you move memory from 'queue' to 'memory_frame' or update status.
    // For this example, let's assume it updates the status to 'approved' in 'memories' collection.
    // Adjust collection based on actual db schema (e.g. 'memory_frame' or 'memories')
    await admin.firestore()
      .collection('memory_frame')
      .doc(memoryId)
      .update({
        status: 'approved',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    // 2. Send FCM
    const userDoc = await admin.firestore().collection('users').doc(studentId).get();
    if (userDoc.exists) {
      const fcmToken = userDoc.data().fcmToken;
      const settings = userDoc.data().notificationSettings;
      
      const memoriesMuted = settings && settings.memoriesEnabled === false;

      if (fcmToken && !memoriesMuted) {
        const message = {
          notification: {
            title: 'Memory Approved \u{1F4F8}', // Camera emoji
            body: `Your photo for "${eventTitle}" is now live on the Memory Wall!`,
          },
          token: fcmToken,
          data: {
            type: 'memory_frame',
            memoryId: memoryId,
          },
        };
        await sendNotification(message);
      }
    }

    res.status(200).json({ success: true, message: 'Memory approved.' });
  } catch (error) {
    console.error('Error approving memory:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
