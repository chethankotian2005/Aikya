/**
 * Authentication middleware — verifies Firebase ID tokens.
 *
 * NEVER trusts a client-sent role. The role is always looked up from
 * Firestore `users/{uid}` after the token is verified.
 *
 * Attaches to `req`:
 *   - req.uid     — Firebase Auth UID
 *   - req.email   — user email from token
 *   - req.role    — role string from Firestore (hod, event_faculty, etc.)
 *
 * Usage:
 *   import { verifyAuth, requireRole } from '../middleware/verifyAuth.js';
 *
 *   router.post('/endpoint', verifyAuth, requireRole('hod', 'event_faculty'), handler);
 */

import admin from 'firebase-admin';

// Lazy — evaluated on first request, well after initializeApp() in index.js.
let _db;
function getDb() {
  if (!_db) _db = admin.firestore();
  return _db;
}

/**
 * Verify the Firebase ID token from the Authorization header.
 * Looks up the user's role from Firestore — never from the token or client.
 */
export async function verifyAuth(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader?.startsWith('Bearer ')) {
    return res.status(401).json({
      error: 'Missing or malformed Authorization header. Expected: Bearer <idToken>',
    });
  }

  const idToken = authHeader.split('Bearer ')[1];

  try {
    // Verify the Firebase ID token
    const decoded = await admin.auth().verifyIdToken(idToken);
    req.uid = decoded.uid;
    req.email = decoded.email;

    // Look up role from Firestore — NEVER trust client-sent role
    const userDoc = await getDb().collection('users').doc(decoded.uid).get();

    if (!userDoc.exists) {
      return res.status(403).json({
        error: 'User profile not found. Please complete registration first.',
      });
    }

    req.role = userDoc.data().role;
    req.userName = userDoc.data().fullName;
    next();
  } catch (err) {
    console.error('Auth verification failed:', err.code || err.message);

    if (err.code === 'auth/id-token-expired') {
      return res.status(401).json({ error: 'Token expired. Please re-authenticate.' });
    }
    if (err.code === 'auth/id-token-revoked') {
      return res.status(401).json({ error: 'Token revoked. Please sign in again.' });
    }

    return res.status(401).json({ error: 'Invalid authentication token.' });
  }
}

/**
 * Role-gate factory — returns middleware that checks if req.role is in
 * the allowed list. Must be used AFTER verifyAuth.
 *
 * @param  {...string} allowedRoles  e.g. 'hod', 'event_faculty'
 * @returns {Function} Express middleware
 */
export function requireRole(...allowedRoles) {
  return (req, res, next) => {
    if (!req.role) {
      return res.status(500).json({ error: 'Auth middleware not applied before role check.' });
    }

    if (!allowedRoles.includes(req.role)) {
      return res.status(403).json({
        error: `Access denied. Required role: ${allowedRoles.join(' or ')}. Your role: ${req.role}`,
      });
    }

    next();
  };
}
