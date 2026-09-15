/**
 * POST /api/compile-accreditation
 *
 * Role-gated: hod only.
 * Takes event IDs + a semester label, pulls event data (and each event's
 * generated report, if any) from Firestore, asks Gemini to compile a
 * structured accreditation document, renders it to PDF via PDFKit, uploads
 * it to Firebase Storage, writes an accreditationReports doc, and returns
 * the download URL.
 *
 * Request body:
 *   { "semesterLabel": "2026 Odd Semester", "eventIds": ["event1", "event2"] }
 *
 * Response:
 *   { "reportId", "pdfUrl", "semesterLabel", "eventCount", "generatedAt" }
 */

import { Router } from 'express';
import admin from 'firebase-admin';
import PDFDocument from 'pdfkit';
import { verifyAuth, requireRole } from '../middleware/verifyAuth.js';
import { geminiLimiter, geminiModel } from '../utils/gemini.js';
import { uploadRawToCloudinary } from '../utils/cloudinary.js';

const router = Router();
let _db;
function db() { if (!_db) _db = admin.firestore(); return _db; }

const MAX_EVENTS = 50;
const MAX_REPORT_CHARS = 4000;

const SYSTEM_PROMPT = `You are an academic accreditation report compiler for the AI & ML department at SMVITM.
Compile the provided event data into a single, well-structured accreditation document.

The document MUST include:
1. A Table of Contents
2. An Executive Summary
3. Individual sections for each event (title, date, description, attendance stats, and a summary of its event report when provided)
4. A consolidated statistics summary (total events, total students, category breakdown)
5. Recommendations and conclusions

Use clear Markdown headings (#, ##, ###), bullet points, and a professional tone.
Be thorough but concise. This document will be converted to a PDF for accreditation review.`;

/**
 * Pull event data + registration/comment counts + generated report for each event ID.
 */
async function gatherEventData(eventIds) {
  const events = [];

  for (const eventId of eventIds) {
    const eventRef = db().collection('events').doc(eventId);
    const eventDoc = await eventRef.get();
    if (!eventDoc.exists) continue;

    const data = eventDoc.data();
    const [regs, comments] = await Promise.all([
      eventRef.collection('registrations').count().get(),
      eventRef.collection('comments').count().get(),
    ]);

    events.push({
      id: eventId,
      title: data.title,
      description: data.description,
      venue: data.venue,
      date: data.eventDate?.toDate?.()?.toISOString() || 'N/A',
      tag: data.tag,
      maxCapacity: data.maxCapacity,
      registrations: regs.data().count,
      commentsCount: comments.data().count,
      sentiment: data.sentiment?.percentages || null,
      eventReport: data.report?.markdown?.slice(0, MAX_REPORT_CHARS) || null,
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
    doc.fillColor('#0E1B3D');

    for (const line of markdownText.split('\n')) {
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

router.post(
  '/compile-accreditation',
  geminiLimiter,
  verifyAuth,
  requireRole('hod'),
  async (req, res) => {
    try {
      const { semesterLabel, eventIds } = req.body;

      if (!semesterLabel || typeof semesterLabel !== 'string' || !semesterLabel.trim()) {
        return res.status(400).json({ error: '"semesterLabel" is required.' });
      }
      if (
        !Array.isArray(eventIds) ||
        eventIds.length === 0 ||
        eventIds.length > MAX_EVENTS ||
        !eventIds.every((id) => typeof id === 'string' && id)
      ) {
        return res
          .status(400)
          .json({ error: `"eventIds" must be a non-empty array of up to ${MAX_EVENTS} event IDs.` });
      }

      const events = await gatherEventData(eventIds);

      if (events.length === 0) {
        return res.status(404).json({ error: 'No valid events found for the given IDs.' });
      }

      const label = semesterLabel.trim();
      const prompt = `Compile an accreditation report for: ${label}

Events data:
${JSON.stringify(events, null, 2)}

Generate a complete, structured Markdown accreditation document.`;

      const result = await geminiModel(SYSTEM_PROMPT).generateContent(prompt);
      const markdown = result.response.text();

      const pdfBuffer = await renderPdf(`Accreditation Report — ${label}`, markdown);

      const publicId = `${label.replace(/[^A-Za-z0-9_-]+/g, '_')}_${Date.now()}`;
      const uploaded = await uploadRawToCloudinary(pdfBuffer, { folder: 'aikya/accreditation-reports', publicId });
      const pdfUrl = uploaded.secure_url;

      const reportRef = db().collection('accreditationReports').doc();
      await reportRef.set({
        semesterLabel: label,
        compiledBy: req.uid,
        includedEventIds: events.map((e) => e.id),
        pdfUrl,
        generatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return res.json({
        reportId: reportRef.id,
        pdfUrl,
        semesterLabel: label,
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
