import { GoogleGenerativeAI } from '@google/generative-ai';
import rateLimit from 'express-rate-limit';

// Google retires Gemini model versions on a rolling basis (gemini-1.5-* were
// retired first, then gemini-2.5-flash on ~2026-09) — if AI features start
// failing with a 404 "model no longer available" error, check
// https://ai.google.dev/gemini-api/docs/models for the current name and
// update the default here, or override via the GEMINI_MODEL env var without
// a redeploy.
export const GEMINI_MODEL = process.env.GEMINI_MODEL || 'gemini-3.6-flash';

export const geminiLimiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '60000', 10),
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '10', 10),
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many AI requests. Please wait before trying again.' },
});

export function geminiModel(systemInstruction) {
  const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
  return genAI.getGenerativeModel({ model: GEMINI_MODEL, systemInstruction });
}
