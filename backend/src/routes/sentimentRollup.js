/**
 * POST /api/analyze-sentiment
 *
 * Role-gated: hod, event_faculty, assistant.
 * Takes an eventId, pulls its comments subcollection, runs each
 * through Gemini for sentiment analysis, writes labels/scores back
 * onto each comment doc, returns aggregated distribution.
 *
 * Request body:
 *   { "eventId": "abc123" }
 *
 * Response:
 *   {
 *     "eventId": "abc123",
 *     "totalComments": 25,
 *     "distribution": { "positive": 15, "neutral": 7, "negative": 3 },
 *     "percentages": { "positive": 60, "neutral": 28, "negative": 12 },
 *     "analyzedAt": "2026-09-04T..."
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
 * Analyze a batch of comments in a single Gemini call for efficiency.
 * Returns an array of { id, label, score, reason } objects.
 */
async function analyzeBatch(comments, model) {
  if (comments.length === 0) return [];

  const prompt = `Analyze the sentiment of each comment below. For each, return a JSON object with:
- "id": the comment ID (provided)
- "label": exactly one of "positive", "neutral", or "negative"
- "score": a confidence score from 0.0 to 1.0
- "reason": a brief 1-sentence explanation

Return ONLY a valid JSON array, no markdown fences, no extra text.

Comments:
${comments.map((c) => `[ID: ${c.id}] "${c.text}"`).join('\n')}`;

  const result = await model.generateContent(prompt);
  const text = result.response.text().trim();

  // Strip markdown code fences if Gemini wraps the response
  const cleaned = text.replace(/^```(?:json)?\n?/i, '').replace(/\n?```$/i, '');

  try {
    return JSON.parse(cleaned);
  } catch {
    console.error('Failed to parse Gemini sentiment response:', cleaned);
    return [];
  }
}

// ── Route ───────────────────────────────────────────────────────────

router.post(
  '/analyze-sentiment',
  geminiLimiter,
  verifyAuth,
  requireRole('hod', 'event_faculty', 'assistant'),
  async (req, res) => {
    try {
      const { eventId } = req.body;

      if (!eventId || typeof eventId !== 'string') {
        return res.status(400).json({ error: '"eventId" is required.' });
      }

      // ── Step 1: Pull comments subcollection ─────────────────────
      const commentsSnap = await db
        .collection('events')
        .doc(eventId)
        .collection('comments')
        .get();

      if (commentsSnap.empty) {
        return res.json({
          eventId,
          totalComments: 0,
          distribution: { positive: 0, neutral: 0, negative: 0 },
          percentages: { positive: 0, neutral: 0, negative: 0 },
          analyzedAt: new Date().toISOString(),
        });
      }

      // Gather comments — skip those already analyzed
      const allComments = [];
      const alreadyAnalyzed = { positive: 0, neutral: 0, negative: 0 };

      commentsSnap.forEach((doc) => {
        const data = doc.data();
        if (data.sentimentLabel) {
          // Already analyzed — count it but don't re-analyze
          alreadyAnalyzed[data.sentimentLabel] =
            (alreadyAnalyzed[data.sentimentLabel] || 0) + 1;
        } else {
          allComments.push({
            id: doc.id,
            text: data.commentText || '',
          });
        }
      });

      // ── Step 2: Batch analyze with Gemini ─────────────────────
      const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
      const model = genAI.getGenerativeModel({
        model: 'gemini-1.5-flash',
        systemInstruction:
          'You are a sentiment analysis engine. Classify student feedback comments about college events as positive, neutral, or negative. Be accurate and fair.',
      });

      // Process in batches of 20 to avoid token limits
      const BATCH_SIZE = 20;
      const results = [];

      for (let i = 0; i < allComments.length; i += BATCH_SIZE) {
        const batch = allComments.slice(i, i + BATCH_SIZE);
        const batchResults = await analyzeBatch(batch, model);
        results.push(...batchResults);
      }

      // ── Step 3: Write sentiment back to Firestore ──────────────
      const writeBatch = db().batch();
      const newCounts = { positive: 0, neutral: 0, negative: 0 };

      for (const item of results) {
        if (!item.id || !item.label) continue;

        const label = ['positive', 'neutral', 'negative'].includes(item.label)
          ? item.label
          : 'neutral';

        newCounts[label]++;

        const commentRef = db
          .collection('events')
          .doc(eventId)
          .collection('comments')
          .doc(item.id);

        writeBatch.update(commentRef, {
          sentimentLabel: label,
          sentimentScore: typeof item.score === 'number' ? item.score : null,
        });
      }

      await writeBatch.commit();

      // ── Step 4: Compute aggregated distribution ────────────────
      const distribution = {
        positive: alreadyAnalyzed.positive + newCounts.positive,
        neutral: alreadyAnalyzed.neutral + newCounts.neutral,
        negative: alreadyAnalyzed.negative + newCounts.negative,
      };

      const total =
        distribution.positive + distribution.neutral + distribution.negative;

      const percentages = {
        positive: total > 0 ? Math.round((distribution.positive / total) * 100) : 0,
        neutral: total > 0 ? Math.round((distribution.neutral / total) * 100) : 0,
        negative: total > 0 ? Math.round((distribution.negative / total) * 100) : 0,
      };

      return res.json({
        eventId,
        totalComments: total,
        newlyAnalyzed: results.length,
        previouslyAnalyzed:
          alreadyAnalyzed.positive +
          alreadyAnalyzed.neutral +
          alreadyAnalyzed.negative,
        distribution,
        percentages,
        analyzedAt: new Date().toISOString(),
      });
    } catch (err) {
      console.error('Sentiment analysis failed:', err);
      return res.status(500).json({
        error: 'Sentiment analysis failed. Please try again.',
      });
    }
  },
);

export default router;
