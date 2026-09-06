/**
 * Health check route — GET /health
 *
 * No authentication required. Used by:
 *  - Render's health check
 *  - A cron job to keep the free-tier instance alive
 */

import { Router } from 'express';

const router = Router();

router.get('/health', (_req, res) => {
  res.json({
    status: 'ok',
    service: 'aikya-backend',
    timestamp: new Date().toISOString(),
  });
});

export default router;
