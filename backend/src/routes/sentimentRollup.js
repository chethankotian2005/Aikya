/**
 * POST /api/sentiment-rollup
 *
 * Role-gated: hod (any event), coordinator (events they created).
 * Pulls an event's comments, runs the un-analysed ones through Gemini,
 * writes labels/scores back onto each comment and a rollup onto the event
 * (`sentiment`), and returns the aggregated distribution.
 *
 * Request body:
 *   { "eventId": "abc123" }
 *
 * Response:
 *   { eventId, totalComments, newlyAnalyzed, previouslyAnalyzed, distribution, percentages, analyzedAt }
 */

import { Router } from 'express';
import admin from 'firebase-admin';
import { verifyAuth, requireRole } from '../middleware/verifyAuth.js';
import { geminiLimiter, geminiModel } from '../utils/gemini.js';
import { getEventForStaff } from '../utils/eventAccess.js';

const router = Router();
let _db;
function db() { if (!_db) _db = admin.firestore(); return _db; }

const LABELS = ['positive', 'neutral', 'negative'];
const BATCH_SIZE = 20;

/**
 * Analyze a batch of comments in a single Gemini call.
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
  const cleaned = text.replace(/^```(?:json)?\n?/i, '').replace(/\n?```$/i, '');

  try {
    return JSON.parse(cleaned);
  } catch {
    console.error('Failed to parse Gemini sentiment response:', cleaned);
    return [];
  }
}

router.post(
  '/sentiment-rollup',
  geminiLimiter,
  verifyAuth,
  requireRole('hod', 'coordinator'),
  async (req, res) => {
    try {
      const { eventId } = req.body;

      const { error, status } = await getEventForStaff(db(), eventId, req);
      if (error) return res.status(status).json({ error });

      const eventRef = db().collection('events').doc(eventId);
      const commentsSnap = await eventRef.collection('comments').get();

      const alreadyAnalyzed = { positive: 0, neutral: 0, negative: 0 };
      const pending = [];

      commentsSnap.forEach((doc) => {
        const data = doc.data();
        if (LABELS.includes(data.sentimentLabel)) {
          alreadyAnalyzed[data.sentimentLabel]++;
        } else {
          pending.push({ id: doc.id, text: data.commentText || '' });
        }
      });

      const validIds = new Set(pending.map((c) => c.id));
      const results = [];

      if (pending.length > 0) {
        const model = geminiModel(
          'You are a sentiment analysis engine. Classify student feedback comments about college events as positive, neutral, or negative. Be accurate and fair.',
        );
        for (let i = 0; i < pending.length; i += BATCH_SIZE) {
          results.push(...(await analyzeBatch(pending.slice(i, i + BATCH_SIZE), model)));
        }
      }

      const writeBatch = db().batch();
      const newCounts = { positive: 0, neutral: 0, negative: 0 };

      for (const item of results) {
        if (!validIds.has(item?.id)) continue;
        validIds.delete(item.id);

        const label = LABELS.includes(item.label) ? item.label : 'neutral';
        newCounts[label]++;

        writeBatch.update(eventRef.collection('comments').doc(item.id), {
          sentimentLabel: label,
          sentimentScore: typeof item.score === 'number' ? item.score : null,
        });
      }

      const distribution = {
        positive: alreadyAnalyzed.positive + newCounts.positive,
        neutral: alreadyAnalyzed.neutral + newCounts.neutral,
        negative: alreadyAnalyzed.negative + newCounts.negative,
      };
      const total = distribution.positive + distribution.neutral + distribution.negative;
      const percentages = Object.fromEntries(
        LABELS.map((l) => [l, total > 0 ? Math.round((distribution[l] / total) * 100) : 0]),
      );

      writeBatch.set(
        eventRef,
        {
          sentiment: {
            distribution,
            percentages,
            totalComments: total,
            analyzedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
        },
        { merge: true },
      );
      await writeBatch.commit();

      return res.json({
        eventId,
        totalComments: total,
        newlyAnalyzed: newCounts.positive + newCounts.neutral + newCounts.negative,
        previouslyAnalyzed:
          alreadyAnalyzed.positive + alreadyAnalyzed.neutral + alreadyAnalyzed.negative,
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
