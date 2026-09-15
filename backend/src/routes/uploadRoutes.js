/**
 * POST /api/upload-image — the only path any client uses to store an image.
 *
 * Firebase Storage now requires the Blaze plan even for free-tier usage, so
 * all image storage (profile pictures, event banners, memory-wall photos,
 * project covers) goes through Cloudinary's free tier instead. The API
 * secret only ever lives on this server — clients never touch Cloudinary
 * directly, they upload here with their Firebase ID token like every other
 * backend call.
 */

import express from 'express';
import multer from 'multer';
import rateLimit from 'express-rate-limit';
import { verifyAuth } from '../middleware/verifyAuth.js';
import { UPLOAD_FOLDERS, uploadToCloudinary } from '../utils/cloudinary.js';

const router = express.Router();

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 },
  fileFilter: (_req, file, cb) => {
    cb(file.mimetype.startsWith('image/') ? null : new Error('Only image files are allowed.'), true);
  },
});

const uploadLimiter = rateLimit({
  windowMs: 5 * 60 * 1000,
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many uploads. Please wait a few minutes before trying again.' },
});

router.post('/upload-image', verifyAuth, uploadLimiter, (req, res) => {
  upload.single('file')(req, res, async (err) => {
    if (err) {
      const status = err.message === 'Only image files are allowed.' ? 400 : err.code === 'LIMIT_FILE_SIZE' ? 413 : 400;
      return res.status(status).json({
        error: err.code === 'LIMIT_FILE_SIZE' ? 'Images must be under 10 MB.' : err.message,
      });
    }

    if (!req.file) {
      return res.status(400).json({ error: 'No file was uploaded.' });
    }

    const { folder } = req.body;
    if (!Object.prototype.hasOwnProperty.call(UPLOAD_FOLDERS, folder)) {
      return res.status(400).json({ error: `folder must be one of: ${Object.keys(UPLOAD_FOLDERS).join(', ')}` });
    }

    try {
      const result = await uploadToCloudinary(req.file.buffer, { folder, uid: req.uid });
      res.status(200).json({ secure_url: result.secure_url });
    } catch (error) {
      console.error('Cloudinary upload failed:', error.message || error);
      res.status(502).json({ error: 'Image upload failed. Please try again.' });
    }
  });
});

export default router;
