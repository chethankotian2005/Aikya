/**
 * Authentication middleware — verifies Firebase ID tokens.
 *
 * NEVER trusts a client-sent role or token claim. The role is always looked
 * up from Firestore `users/{uid}` after the token is verified.
 *
 * Attaches to `req`:
 *   - req.uid, req.email
 *   - req.role         — student | faculty | coordinator | hod
 *   - req.userName, req.designation, req.club
 *
 * Usage:
 *   router.post('/endpoint', verifyAuth, requireRole('hod', 'coordinator'), handler);
 */

import admin from 'firebase-admin';

// Lazy — evaluated on first request, well after initializeApp() in index.js.
let _db;
function getDb() {
  if (!_db) _db = admin.firestore();
  return _db;
}

export async function verifyAuth(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader?.startsWith('Bearer ')) {
    return res.status(401).json({
      error: 'Missing or malformed Authorization header. Expected: Bearer <idToken>',
    });
  }

  const idToken = authHeader.split('Bearer ')[1];

  try {
    const decoded = await admin.auth().verifyIdToken(idToken);
    req.uid = decoded.uid;
    req.email = decoded.email;

    const userDoc = await getDb().collection('users').doc(decoded.uid).get();

    if (!userDoc.exists) {
      return res.status(403).json({
        error: 'User profile not found. Please complete registration first.',
      });
    }

    const data = userDoc.data();
    req.role = data.role;
    req.userName = data.fullName;
    req.designation = data.designation || null;
    req.club = data.club || null;
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
 * Role-gate factory — must be used AFTER verifyAuth.
 */
export function requireRole(...allowedRoles) {
  return (req, res, next) => {
    if (!req.role) {
      return res.status(500).json({ error: 'Auth middleware not applied before role check.' });
    }

    if (!allowedRoles.includes(req.role)) {
      return res.status(403).json({
        error: `Access denied. Required role: ${allowedRoles.join(' or ')}.`,
      });
    }

    next();
  };
}
