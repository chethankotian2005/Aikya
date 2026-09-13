import 'dotenv/config';
import admin from 'firebase-admin';

// Initialize Firebase Admin if not already initialized
const serviceAccount = process.env.FIREBASE_SERVICE_ACCOUNT
  ? JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT)
  : undefined;

admin.initializeApp({
  credential: serviceAccount
    ? admin.credential.cert(serviceAccount)
    : admin.credential.applicationDefault(),
  storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
});

const coordinatorData = [
  { facultyId: 'C001', fullName: 'Coordinator One', designation: 'Technical Club Coordinator', role: 'coordinator', club: 'Technical Club' },
  { facultyId: 'C002', fullName: 'Coordinator Two', designation: 'Cultural Club Coordinator', role: 'coordinator', club: 'Cultural Club' },
  { facultyId: 'C003', fullName: 'Coordinator Three', designation: 'Sports Club Coordinator', role: 'coordinator', club: 'Sports Club' },
  { facultyId: 'C004', fullName: 'Coordinator Four', designation: 'Literary Club Coordinator', role: 'coordinator', club: 'Literary Club' },
  { facultyId: 'C005', fullName: 'Coordinator Five', designation: 'Innovation Club Coordinator', role: 'coordinator', club: 'Innovation Club' },
];

async function seedCoordinators() {
  console.log('Seeding coordinator accounts...');

  for (const person of coordinatorData) {
    const { facultyId, fullName, designation, role, club } = person;
    const email = `${facultyId.trim().toLowerCase().replace(/\s/g, '')}@aikya.internal`;
    const password = `${facultyId}pass`; // Setting a permanent password like C001pass

    try {
      let userRecord;
      try {
        userRecord = await admin.auth().createUser({
          email: email,
          password: password,
          displayName: fullName,
        });
        console.log(`Created Auth user for ${facultyId}`);
      } catch (authError) {
        if (authError.code === 'auth/email-already-exists') {
          userRecord = await admin.auth().getUserByEmail(email);
          // Optional: Update password if needed
          await admin.auth().updateUser(userRecord.uid, { password: password });
          console.log(`Auth user ${facultyId} already exists. Password reset.`);
        } else {
          throw authError;
        }
      }

      const claims = { role };
      if (club) claims.club = club;
      await admin.auth().setCustomUserClaims(userRecord.uid, claims);

      const userDoc = {
        uid: userRecord.uid,
        email: email,
        facultyId: facultyId,
        fullName: fullName,
        role: role,
        designation: designation,
        mustResetPassword: false, // Per user request: no need to reset
        profileComplete: true,
      };

      if (club) userDoc.club = club;

      await admin.firestore().collection('users').doc(userRecord.uid).set(userDoc, { merge: true });
      console.log(`Provisioned ${facultyId} successfully.`);
    } catch (err) {
      console.error(`Error provisioning ${facultyId}:`, err);
    }
  }

  console.log('Coordinator seeding complete.');
  process.exit(0);
}

seedCoordinators();
