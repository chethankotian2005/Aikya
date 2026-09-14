/**
 * Health check — GET /api/health (spec §7) and GET /health (Render's configured check).
 *
 * No authentication required. Used by Render's health check and the
 * GitHub Actions keep-alive cron.
 */

import { Router } from 'express';

const router = Router();

router.get(['/health', '/api/health'], (_req, res) => {
  res.json({
    status: 'ok',
    service: 'aikya-backend',
    timestamp: new Date().toISOString(),
  });
});

export default router;
