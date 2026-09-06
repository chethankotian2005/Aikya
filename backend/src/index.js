/**
 * AIKYA Backend — Express entry point.
 *
 * Initializes Firebase Admin, mounts routes, configures CORS + security.
 * Designed for deployment on Render (PORT from env).
 */

import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import admin from 'firebase-admin';

import healthRouter from './routes/health.js';
import reportGeneratorRouter from './routes/reportGenerator.js';
import accreditationCompilerRouter from './routes/accreditationCompiler.js';
import sentimentRollupRouter from './routes/sentimentRollup.js';
import profileRoutes from './routes/profileRoutes.js';

// ── Firebase Admin Init ─────────────────────────────────────────────

const serviceAccount = process.env.FIREBASE_SERVICE_ACCOUNT
  ? JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT)
  : undefined; // Falls back to GOOGLE_APPLICATION_CREDENTIALS file

admin.initializeApp({
  credential: serviceAccount
    ? admin.credential.cert(serviceAccount)
    : admin.credential.applicationDefault(),
  storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
});

// ── Express App ─────────────────────────────────────────────────────

const app = express();

// Security headers
app.use(helmet());

// Request logging
app.use(morgan('short'));

// Body parsing
app.use(express.json({ limit: '5mb' }));

// CORS — locked to allowed origins (Flutter web domain, localhost dev)
const allowedOrigins = (process.env.ALLOWED_ORIGINS || '')
  .split(',')
  .map((o) => o.trim())
  .filter(Boolean);

app.use(
  cors({
    origin: (origin, callback) => {
      // Allow requests with no origin (mobile apps, curl, server-to-server)
      if (!origin || allowedOrigins.includes(origin)) {
        callback(null, true);
      } else {
        callback(new Error(`CORS: origin ${origin} not allowed`));
      }
    },
    methods: ['GET', 'POST', 'PUT'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    maxAge: 86400,
  }),
);

// ── Routes ──────────────────────────────────────────────────────────

// Health check — no auth, used by Render keep-alive cron
app.use('/', healthRouter);

// AI-powered routes — auth required, rate limited
app.use('/api', reportGeneratorRouter);
app.use('/api', accreditationCompilerRouter);
app.use('/api', sentimentRollupRouter);
app.use('/api', profileRoutes);

// ── 404 fallback ────────────────────────────────────────────────────

app.use((_req, res) => {
  res.status(404).json({ error: 'Not found' });
});

// ── Global error handler ────────────────────────────────────────────

app.use((err, _req, res, _next) => {
  console.error('Unhandled error:', err);
  const status = err.status || 500;
  res.status(status).json({
    error: err.message || 'Internal server error',
  });
});

// ── Start ───────────────────────────────────────────────────────────

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`[AIKYA] Server running on port ${PORT}`);
  console.log(`[AIKYA] Health check: http://localhost:${PORT}/health`);
});

export default app;
