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

/**
 * Gemini's shared/free tier returns transient 503 "model overloaded" errors
 * fairly often — observed failing ~1 in 2-3 real requests in production.
 * One retry with a short backoff clears almost all of them without making
 * the user click "try again" themselves.
 */
export async function generateWithRetry(model, prompt, { retries = 2, delayMs = 1500 } = {}) {
  let lastErr;
  for (let attempt = 0; attempt <= retries; attempt++) {
    try {
      return await model.generateContent(prompt);
    } catch (err) {
      lastErr = err;
      const overloaded = err.status === 503 || /overloaded|unavailable/i.test(err.message || '');
      if (!overloaded || attempt === retries) throw err;
      await new Promise((resolve) => setTimeout(resolve, delayMs * (attempt + 1)));
    }
  }
  throw lastErr;
}
