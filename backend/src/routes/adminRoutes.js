import express from 'express';
import admin from 'firebase-admin';

const router = express.Router();

// Middleware to verify the user is HOD
// In a real scenario, you'd use a verifyToken middleware first
const verifyHod = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Unauthorized: Missing or invalid token' });
  }

  const idToken = authHeader.split('Bearer ')[1];
  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    if (decodedToken.role !== 'hod') {
      return res.status(403).json({ error: 'Forbidden: Requires HOD role' });
    }
    req.user = decodedToken;
    next();
  } catch (error) {
    console.error('Error verifying HOD token:', error);
    return res.status(401).json({ error: 'Unauthorized: Token verification failed' });
  }
};

/**
 * POST /api/admin/provision-staff
 * Body: { staff: [ { facultyId, fullName, designation, role, club? } ] }
 */
router.post('/provision-staff', verifyHod, async (req, res) => {
  const { staff } = req.body;

  if (!Array.isArray(staff)) {
    return res.status(400).json({ error: 'Invalid request body, expected staff array' });
  }

  const results = [];
  const errors = [];

  for (const person of staff) {
    const { facultyId, fullName, designation, role, club } = person;

    if (!facultyId || !fullName || !role) {
      errors.push({ facultyId, error: 'Missing required fields' });
      continue;
    }

    try {
      const email = `${facultyId.trim().toLowerCase().replace(/\s/g, '')}@aikya.internal`;
      const password = `${facultyId}@ml`;

      // 1. Create the Auth user
      let userRecord;
      try {
         userRecord = await admin.auth().createUser({
          email: email,
          password: password,
          displayName: fullName,
        });
      } catch (authError) {
        if (authError.code === 'auth/email-already-exists') {
          userRecord = await admin.auth().getUserByEmail(email);
        } else {
          throw authError;
        }
      }

      // 2. Set custom claims for role (and club)
      const claims = { role };
      if (club) claims.club = club;
      await admin.auth().setCustomUserClaims(userRecord.uid, claims);

      // 3. Write Firestore doc
      const userDoc = {
        uid: userRecord.uid,
        email: email,
        facultyId: facultyId,
        fullName: fullName,
        role: role,
        mustResetPassword: true,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        profileComplete: true, // They are staff, skip profile setup for now
      };

      if (designation) userDoc.designation = designation;
      if (club) userDoc.club = club;

      await admin.firestore().collection('users').doc(userRecord.uid).set(userDoc, { merge: true });

      results.push({ facultyId, status: 'Success' });
    } catch (err) {
      console.error(`Error provisioning ${facultyId}:`, err);
      errors.push({ facultyId, error: err.message });
    }
  }

  res.status(200).json({
    message: 'Provisioning complete',
    results,
    errors,
  });
});

export default router;
