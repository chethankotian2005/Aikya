/**
 * QR-based attendance (spec §6/§7). Replaces the old manual
 * attendanceRequests approve/reject flow — the scan itself is the record,
 * no separate HOD approval step needed.
 *
 *   POST /api/attendance/scan   faculty, coordinator (own events), hod
 *   POST /api/attendance/sheet  faculty, coordinator (own events), hod
 *
 * Each student has a personal QR (their uid, generated client-side — no
 * network round-trip). A coordinator/faculty/HOD scans it with a camera
 * during the event; the scan is validated and recorded server-side so a
 * screenshot of someone else's QR can't be self-reported from the client.
 */

import { Router } from 'express';
import admin from 'firebase-admin';
import PDFDocument from 'pdfkit';
import { verifyAuth, requireRole } from '../middleware/verifyAuth.js';
import { getEventForStaff } from '../utils/eventAccess.js';
import { uploadRawToCloudinary } from '../utils/cloudinary.js';
import { createLetterheadDoc, drawDocumentTitle, stampLetterheadOnAllPages } from '../utils/pdfTemplate.js';

const router = Router();
let _db;
function db() { if (!_db) _db = admin.firestore(); return _db; }

const VALID_SESSIONS = ['full', 'morning', 'afternoon'];

router.post('/attendance/scan', verifyAuth, requireRole('faculty', 'coordinator', 'hod'), async (req, res) => {
  try {
    const { eventId, studentUid, session } = req.body;

    if (typeof studentUid !== 'string' || !studentUid) {
      return res.status(400).json({ error: '"studentUid" is required.' });
    }
    const sessionKey = typeof session === 'string' && VALID_SESSIONS.includes(session) ? session : 'full';

    const { event, status, error } = await getEventForStaff(db(), eventId, req);
    if (error) return res.status(status).json({ error });

    const sessions = Array.isArray(event.sessions) && event.sessions.length > 0 ? event.sessions : ['full'];
    if (!sessions.includes(sessionKey)) {
      return res.status(400).json({ error: `This event doesn't have a "${sessionKey}" session.` });
    }

    const regSnap = await db().collection('events').doc(eventId).collection('registrations').doc(studentUid).get();
    if (!regSnap.exists) {
      return res.status(404).json({ error: 'This student isn’t registered for this event.' });
    }

    const studentSnap = await db().collection('users').doc(studentUid).get();
    if (!studentSnap.exists || studentSnap.data().role !== 'student') {
      return res.status(404).json({ error: 'Student account not found.' });
    }
    const student = studentSnap.data();

    const recordId = `${studentUid}_${sessionKey}`;
    const recordRef = db().collection('events').doc(eventId).collection('attendance').doc(recordId);
    const existing = await recordRef.get();
    if (existing.exists) {
      return res.status(200).json({
        success: true,
        alreadyMarked: true,
        studentName: student.fullName,
        usn: student.usn || null,
      });
    }

    await recordRef.set({
      eventId,
      studentUid,
      studentName: student.fullName,
      usn: student.usn || null,
      session: sessionKey,
      scannedBy: req.uid,
      scannedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return res.status(200).json({
      success: true,
      alreadyMarked: false,
      studentName: student.fullName,
      usn: student.usn || null,
    });
  } catch (err) {
    console.error('Attendance scan failed:', err);
    return res.status(500).json({ error: 'Could not record attendance. Please try again.' });
  }
});

/** Renders a sorted-by-USN attendance sheet PDF onto the department letterhead. */
function renderAttendanceSheetPdf(eventTitle, sessions, rowsBySession) {
  return new Promise((resolve, reject) => {
    const doc = createLetterheadDoc(PDFDocument, { title: `Attendance Sheet — ${eventTitle}` });
    const chunks = [];
    doc.on('data', (chunk) => chunks.push(chunk));
    doc.on('end', () => resolve(Buffer.concat(chunks)));
    doc.on('error', reject);

    drawDocumentTitle(doc, 'ATTENDANCE SHEET', eventTitle);

    const sessionLabels = { full: 'Attendance', morning: 'Morning Session', afternoon: 'Afternoon Session' };
    for (const session of sessions) {
      const rows = rowsBySession[session] || [];
      doc.fontSize(13).font('Helvetica-Bold').fillColor('#0E1B3D').text(sessionLabels[session] || session);
      doc.moveDown(0.3);
      doc.fontSize(9.5).font('Helvetica').fillColor('#4A5A7A').text(`${rows.length} student(s) present`);
      doc.moveDown(0.5);

      const colUsn = doc.page.margins.left;
      const colName = colUsn + 110;
      const colTime = doc.page.width - doc.page.margins.right - 90;

      doc.fontSize(9.5).font('Helvetica-Bold').fillColor('#0E1B3D');
      doc.text('USN', colUsn, doc.y, { continued: false });
      doc.text('Name', colName, doc.y - doc.currentLineHeight(), { continued: false });
      doc.text('Scanned At', colTime, doc.y - doc.currentLineHeight(), { continued: false });
      doc.moveDown(0.3);
      doc.moveTo(colUsn, doc.y).lineTo(doc.page.width - doc.page.margins.right, doc.y).strokeColor('#1F5C99').lineWidth(0.5).stroke();
      doc.moveDown(0.3);

      doc.font('Helvetica').fontSize(9.5).fillColor('#0E1B3D');
      if (rows.length === 0) {
        doc.text('No students scanned for this session.', colUsn, doc.y);
        doc.moveDown(0.5);
      }
      for (const row of rows) {
        const rowY = doc.y;
        doc.text(row.usn || '—', colUsn, rowY);
        doc.text(row.studentName, colName, rowY);
        doc.text(row.scannedAt, colTime, rowY);
        doc.moveDown(0.35);
      }
      doc.moveDown(1);
    }

    stampLetterheadOnAllPages(doc);
    doc.end();
  });
}

router.post('/attendance/sheet', verifyAuth, requireRole('faculty', 'coordinator', 'hod'), async (req, res) => {
  try {
    const { eventId } = req.body;
    const { event, status, error } = await getEventForStaff(db(), eventId, req);
    if (error) return res.status(status).json({ error });

    const sessions = Array.isArray(event.sessions) && event.sessions.length > 0 ? event.sessions : ['full'];
    const attendanceSnap = await db().collection('events').doc(eventId).collection('attendance').get();

    const rowsBySession = {};
    for (const session of sessions) rowsBySession[session] = [];
    for (const doc_ of attendanceSnap.docs) {
      const data = doc_.data();
      const session = sessions.includes(data.session) ? data.session : sessions[0];
      rowsBySession[session].push({
        usn: data.usn,
        studentName: data.studentName,
        scannedAt: data.scannedAt?.toDate?.()?.toLocaleString('en-IN', { dateStyle: 'short', timeStyle: 'short' }) || '—',
        _sortUsn: data.usn || '',
      });
    }
    for (const session of sessions) {
      rowsBySession[session].sort((a, b) => a._sortUsn.localeCompare(b._sortUsn));
    }

    const pdfBuffer = await renderAttendanceSheetPdf(event.title, sessions, rowsBySession);
    const publicId = `${event.title.replace(/[^A-Za-z0-9_-]+/g, '_')}_${Date.now()}`;
    const uploaded = await uploadRawToCloudinary(pdfBuffer, { folder: 'aikya/attendance-sheets', publicId });

    return res.status(200).json({ success: true, pdfUrl: uploaded.secure_url });
  } catch (err) {
    console.error('Attendance sheet generation failed:', err);
    return res.status(500).json({ error: 'Could not generate the attendance sheet. Please try again.' });
  }
});

export default router;
