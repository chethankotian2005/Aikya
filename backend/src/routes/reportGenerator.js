/**
 * POST /api/generate-report
 *
 * Role-gated: hod, event_faculty only.
 * Takes a brief + optional event data, calls Gemini 1.5 Flash,
 * returns formatted markdown.
 *
 * Request body:
 *   {
 *     "brief": "Generate a report on Neural Hack 2026...",
 *     "eventId": "optional-event-id",
 *     "includeAttendance": true,
 *     "additionalContext": "EXIF data, photos metadata, etc."
 *   }
 *
 * Response:
 *   {
 *     "markdown": "# Neural Hack 2026 Report\n\n## Executive Summary...",
 *     "model": "gemini-1.5-flash",
 *     "generatedAt": "2026-09-04T..."
 *   }
 */

import { Router } from 'express';
import { GoogleGenerativeAI } from '@google/generative-ai';
import rateLimit from 'express-rate-limit';
import admin from 'firebase-admin';
import { verifyAuth, requireRole } from '../middleware/verifyAuth.js';

const router = Router();
let _db;
function db() { if (!_db) _db = admin.firestore(); return _db; }

// ── Rate limiter for Gemini routes ──────────────────────────────────

const geminiLimiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '60000', 10),
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '10', 10),
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    error: 'Too many AI requests. Please wait before trying again.',
  },
});

// ── Route ───────────────────────────────────────────────────────────

router.post(
  '/generate-report',
  geminiLimiter,
  verifyAuth,
  requireRole('hod', 'event_faculty'),
  async (req, res) => {
    try {
      const { brief, eventId, includeAttendance, additionalContext } = req.body;

      if (!brief || typeof brief !== 'string' || brief.trim().length < 10) {
        return res.status(400).json({
          error: 'A "brief" field (min 10 characters) is required.',
        });
      }

      // Optionally pull event data from Firestore for grounding
      let eventContext = '';
      if (eventId) {
        const eventDoc = await db().collection('events').doc(eventId).get();
        if (eventDoc.exists) {
          const e = eventDoc.data();
          eventContext = `
Event Details:
- Title: ${e.title}
- Date: ${e.eventDate?.toDate?.()?.toISOString() || 'N/A'}
- Venue: ${e.venue}
- Registrations: ${e.currentRegistrations}/${e.maxCapacity}
- Tag: ${e.tag}
- Description: ${e.description}
`;

          // Pull registration count if requested
          if (includeAttendance) {
            const regsSnap = await db
              .collection('events')
              .doc(eventId)
              .collection('registrations')
              .get();
            eventContext += `- Total Registered Students: ${regsSnap.size}\n`;
          }
        }
      }

      // Build the Gemini prompt
      const systemPrompt = `You are AIKYA's AI report generator for the AI & ML department at SMVITM.
Generate a well-structured, professional report in Markdown format.
Use clear headings, bullet points, and tables where appropriate.
Be factual and concise. If event data is provided, incorporate it accurately.
The report should be suitable for accreditation documentation.`;

      const userPrompt = `${brief}

${eventContext ? `\n--- EVENT DATA ---\n${eventContext}` : ''}
${additionalContext ? `\n--- ADDITIONAL CONTEXT ---\n${additionalContext}` : ''}

Generate a comprehensive, formatted Markdown report.`;

      // Call Gemini 1.5 Flash
      const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
      const model = genAI.getGenerativeModel({
        model: 'gemini-1.5-flash',
        systemInstruction: systemPrompt,
      });

      const result = await model.generateContent(userPrompt);
      const markdown = result.response.text();

      return res.json({
        markdown,
        model: 'gemini-1.5-flash',
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
