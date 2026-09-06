/**
 * POST /api/compile-accreditation
 *
 * Role-gated: hod only.
 * Takes an array of event report IDs + semester label, pulls event data
 * from Firestore, asks Gemini to compile a structured accreditation
 * document with table of contents, renders to PDF via PDFKit, uploads
 * to Firebase Storage, writes an accreditationReports doc, returns the
 * download URL.
 *
 * Request body:
 *   {
 *     "semesterLabel": "2026 Odd Semester",
 *     "eventIds": ["event1", "event2", "event3"]
 *   }
 *
 * Response:
 *   {
 *     "reportId": "abc123",
 *     "pdfUrl": "https://storage.googleapis.com/...",
 *     "semesterLabel": "2026 Odd Semester",
 *     "eventCount": 3,
 *     "generatedAt": "2026-09-04T..."
 *   }
 */

import { Router } from 'express';
import { GoogleGenerativeAI } from '@google/generative-ai';
import rateLimit from 'express-rate-limit';
import admin from 'firebase-admin';
import PDFDocument from 'pdfkit';
import { verifyAuth, requireRole } from '../middleware/verifyAuth.js';

const router = Router();
let _db;
function db() { if (!_db) _db = admin.firestore(); return _db; }

// ── Rate limiter ────────────────────────────────────────────────────

const geminiLimiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '60000', 10),
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '10', 10),
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many AI requests. Please wait before trying again.' },
});

// ── Helpers ─────────────────────────────────────────────────────────

/**
 * Pull event data + registration count + comments for each event ID.
 */
async function gatherEventData(eventIds) {
  const events = [];

  for (const eventId of eventIds) {
    const eventDoc = await db().collection('events').doc(eventId).get();
    if (!eventDoc.exists) continue;

    const data = eventDoc.data();
    const regsSnap = await db
      .collection('events')
      .doc(eventId)
      .collection('registrations')
      .get();

    const commentsSnap = await db
      .collection('events')
      .doc(eventId)
      .collection('comments')
      .get();

    events.push({
      id: eventId,
      title: data.title,
      description: data.description,
      venue: data.venue,
      date: data.eventDate?.toDate?.()?.toISOString() || 'N/A',
      tag: data.tag,
      maxCapacity: data.maxCapacity,
      registrations: regsSnap.size,
      commentsCount: commentsSnap.size,
    });
  }

  return events;
}

/**
 * Render markdown-like text to a PDF buffer using PDFKit.
 * Parses basic heading (#, ##, ###), bullet points, and body text.
 */
function renderPdf(title, markdownText) {
  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({
      size: 'A4',
      margins: { top: 60, bottom: 60, left: 60, right: 60 },
      info: {
        Title: title,
        Author: 'AIKYA — AI & ML Department',
        Creator: 'AIKYA Accreditation Compiler',
      },
    });

    const chunks = [];
    doc.on('data', (chunk) => chunks.push(chunk));
    doc.on('end', () => resolve(Buffer.concat(chunks)));
    doc.on('error', reject);

    // ── Title page ──────────────────────────────────────────────
    doc.fontSize(28).font('Helvetica-Bold').text(title, { align: 'center' });
    doc.moveDown(0.5);
    doc
      .fontSize(14)
      .font('Helvetica')
      .fillColor('#1F5C99')
      .text('AI & ML Department — SMVITM', { align: 'center' });
    doc
      .fontSize(11)
      .fillColor('#4A5A7A')
      .text(`Generated: ${new Date().toLocaleDateString('en-IN', { dateStyle: 'long' })}`, {
        align: 'center',
      });
    doc.moveDown(2);
    doc.fillColor('#0E1B3D'); // Reset to primary

    // ── Content ─────────────────────────────────────────────────
    const lines = markdownText.split('\n');

    for (const line of lines) {
      const trimmed = line.trim();

      if (trimmed.startsWith('### ')) {
        doc.moveDown(0.5);
        doc.fontSize(13).font('Helvetica-Bold').text(trimmed.slice(4));
        doc.moveDown(0.2);
      } else if (trimmed.startsWith('## ')) {
        doc.moveDown(0.8);
        doc.fontSize(16).font('Helvetica-Bold').text(trimmed.slice(3));
        doc.moveDown(0.3);
      } else if (trimmed.startsWith('# ')) {
        doc.addPage();
        doc.fontSize(20).font('Helvetica-Bold').text(trimmed.slice(2));
        doc.moveDown(0.5);
      } else if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        doc
          .fontSize(11)
          .font('Helvetica')
          .text(`  •  ${trimmed.slice(2)}`, { indent: 16 });
      } else if (trimmed === '') {
        doc.moveDown(0.4);
      } else {
        doc.fontSize(11).font('Helvetica').text(trimmed, {
          align: 'justify',
          lineGap: 3,
        });
      }
    }

    doc.end();
  });
}

// ── Route ───────────────────────────────────────────────────────────

router.post(
  '/compile-accreditation',
  geminiLimiter,
  verifyAuth,
  requireRole('hod'),
  async (req, res) => {
    try {
      const { semesterLabel, eventIds } = req.body;

      if (!semesterLabel || typeof semesterLabel !== 'string') {
        return res.status(400).json({ error: '"semesterLabel" is required.' });
      }
      if (!Array.isArray(eventIds) || eventIds.length === 0) {
        return res
          .status(400)
          .json({ error: '"eventIds" must be a non-empty array.' });
      }

      // ── Step 1: Gather all event data ───────────────────────────
      const events = await gatherEventData(eventIds);

      if (events.length === 0) {
        return res.status(404).json({ error: 'No valid events found for the given IDs.' });
      }

      // ── Step 2: Ask Gemini to compile into structured document ──
      const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
      const model = genAI.getGenerativeModel({
        model: 'gemini-1.5-flash',
        systemInstruction: `You are an academic accreditation report compiler for the AI & ML department at SMVITM.
Compile the provided event data into a single, well-structured accreditation document.

The document MUST include:
1. A Table of Contents
2. An Executive Summary
3. Individual sections for each event (title, date, description, attendance stats)
4. A consolidated statistics summary (total events, total students, category breakdown)
5. Recommendations and conclusions

Use clear Markdown headings (#, ##, ###), bullet points, and a professional tone.
Be thorough but concise. This document will be converted to a PDF for accreditation review.`,
      });

      const prompt = `Compile an accreditation report for: ${semesterLabel}

Events data:
${JSON.stringify(events, null, 2)}

Generate a complete, structured Markdown accreditation document.`;

      const result = await model.generateContent(prompt);
      const markdown = result.response.text();

      // ── Step 3: Render to PDF ───────────────────────────────────
      const pdfTitle = `Accreditation Report — ${semesterLabel}`;
      const pdfBuffer = await renderPdf(pdfTitle, markdown);

      // ── Step 4: Upload to Firebase Storage ──────────────────────
      const bucket = admin.storage().bucket();
      const fileName = `accreditation-reports/${semesterLabel.replace(/\s+/g, '_')}_${Date.now()}.pdf`;
      const file = bucket.file(fileName);

      await file.save(pdfBuffer, {
        metadata: {
          contentType: 'application/pdf',
          metadata: {
            compiledBy: req.uid,
            semesterLabel,
            eventCount: String(events.length),
          },
        },
      });

      // Make the file publicly readable (or use signed URLs)
      await file.makePublic();
      const pdfUrl = `https://storage.googleapis.com/${bucket.name}/${fileName}`;

      // ── Step 5: Write Firestore doc ─────────────────────────────
      const reportRef = db().collection('accreditationReports').doc();
      await reportRef.set({
        semesterLabel,
        compiledBy: req.uid,
        includedEventIds: eventIds,
        pdfUrl,
        generatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return res.json({
        reportId: reportRef.id,
        pdfUrl,
        semesterLabel,
        eventCount: events.length,
        generatedAt: new Date().toISOString(),
      });
    } catch (err) {
      console.error('Accreditation compilation failed:', err);
      return res.status(500).json({
        error: 'Accreditation compilation failed. Please try again.',
      });
    }
  },
);

export default router;
