/**
 * POST /api/generate-report
 *
 * Role-gated: hod (any event), coordinator (events they created).
 * Takes a brief + optional event data, calls Gemini, returns formatted
 * markdown and saves it onto the event as `report` so the accreditation
 * compiler and event pages can use it.
 *
 * Request body:
 *   {
 *     "brief": "Generate a report on Neural Hack 2026...",
 *     "eventId": "event-id (required for coordinators)",
 *     "includeAttendance": true,
 *     "additionalContext": "EXIF data, photos metadata, etc."
 *   }
 *
 * Response:
 *   { "markdown": "...", "model": "...", "eventId": "...", "generatedBy": "...", "generatedAt": "..." }
 */

import { Router } from 'express';
import admin from 'firebase-admin';
import PDFDocument from 'pdfkit';
import { verifyAuth, requireRole } from '../middleware/verifyAuth.js';
import { GEMINI_MODEL, generateWithRetry, geminiLimiter, geminiModel } from '../utils/gemini.js';
import { getEventForStaff } from '../utils/eventAccess.js';
import { uploadRawToCloudinary } from '../utils/cloudinary.js';
import { createLetterheadDoc, drawDocumentTitle, renderMarkdownBody, stampLetterheadOnAllPages } from '../utils/pdfTemplate.js';

const router = Router();
let _db;
function db() { if (!_db) _db = admin.firestore(); return _db; }

const SYSTEM_PROMPT = `You are AIKYA's AI report generator for the AI & ML department at SMVITM.
Generate a well-structured, professional report in Markdown format.
Use clear headings, bullet points, and tables where appropriate.
Be factual and concise. If event data is provided, incorporate it accurately.
The report should be suitable for accreditation documentation.`;

/** Renders a generated report onto the department's official letterhead. */
function renderReportPdf(eventTitle, markdown) {
  return new Promise((resolve, reject) => {
    const doc = createLetterheadDoc(PDFDocument, { title: `Event Report — ${eventTitle}` });
    const chunks = [];
    doc.on('data', (chunk) => chunks.push(chunk));
    doc.on('end', () => resolve(Buffer.concat(chunks)));
    doc.on('error', reject);

    drawDocumentTitle(doc, 'EVENT REPORT', eventTitle);
    doc
      .fontSize(9)
      .font('Helvetica')
      .fillColor('#4A5A7A')
      .text(`Generated: ${new Date().toLocaleDateString('en-IN', { dateStyle: 'long' })}`, { align: 'center' });
    doc.moveDown(1.5);
    doc.fillColor('#0E1B3D');

    renderMarkdownBody(doc, markdown);

    stampLetterheadOnAllPages(doc);
    doc.end();
  });
}

router.post(
  '/generate-report',
  geminiLimiter,
  verifyAuth,
  requireRole('hod', 'coordinator'),
  async (req, res) => {
    try {
      const { brief, eventId, includeAttendance, additionalContext } = req.body;

      if (!brief || typeof brief !== 'string' || brief.trim().length < 10) {
        return res.status(400).json({
          error: 'A "brief" field (min 10 characters) is required.',
        });
      }

      if (req.role === 'coordinator' && !eventId) {
        return res.status(400).json({ error: 'Coordinators must pick one of their events.' });
      }

      let eventContext = '';
      let eventTitle = 'Department Activity Report';
      if (eventId) {
        const { event, status, error } = await getEventForStaff(db(), eventId, req);
        if (error) return res.status(status).json({ error });
        eventTitle = event.title;

        eventContext = `
Event Details:
- Title: ${event.title}
- Date: ${event.eventDate?.toDate?.()?.toISOString() || 'N/A'}
- Venue: ${event.venue}
- Registrations: ${event.currentRegistrations}/${event.maxCapacity}
- Tag: ${event.tag || 'N/A'}
- Description: ${event.description}
`;

        if (includeAttendance) {
          const regs = await db()
            .collection('events')
            .doc(eventId)
            .collection('registrations')
            .count()
            .get();
          eventContext += `- Total Registered Students: ${regs.data().count}\n`;
        }
      }

      const userPrompt = `${brief}

${eventContext ? `\n--- EVENT DATA ---\n${eventContext}` : ''}
${additionalContext ? `\n--- ADDITIONAL CONTEXT ---\n${additionalContext}` : ''}

Generate a comprehensive, formatted Markdown report.`;

      const result = await generateWithRetry(geminiModel(SYSTEM_PROMPT), userPrompt);
      const markdown = result.response.text();

      const pdfBuffer = await renderReportPdf(eventTitle, markdown);
      const publicId = `${eventTitle.replace(/[^A-Za-z0-9_-]+/g, '_')}_${Date.now()}`;
      const uploaded = await uploadRawToCloudinary(pdfBuffer, { folder: 'aikya/event-reports', publicId });
      const pdfUrl = uploaded.secure_url;

      if (eventId) {
        await db().collection('events').doc(eventId).set(
          {
            report: {
              markdown,
              pdfUrl,
              model: GEMINI_MODEL,
              generatedBy: req.uid,
              generatedAt: admin.firestore.FieldValue.serverTimestamp(),
            },
          },
          { merge: true },
        );
      }

      return res.json({
        markdown,
        pdfUrl,
        model: GEMINI_MODEL,
        eventId: eventId || null,
        generatedBy: req.uid,
        generatedAt: new Date().toISOString(),
      });
    } catch (err) {
      console.error('Report generation failed:', err);

      if (err.message?.includes('API_KEY')) {
        return res.status(500).json({ error: 'Gemini API key misconfigured.' });
      }

      return res.status(500).json({
        error: 'Report generation failed. Please try again.',
      });
    }
  },
);

export default router;
