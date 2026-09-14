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

const facultyData = [
  { facultyId: '0544', fullName: 'Dr. Rajesh Nayak', designation: 'Associate Professor & HOD', role: 'hod' },
  { facultyId: '0557', fullName: 'Ms. Mamatha', designation: 'Assistant Professor', role: 'faculty' },
  { facultyId: '0504', fullName: 'Ms. Ashwini K', designation: 'Assistant Professor', role: 'faculty' },
  { facultyId: '0539', fullName: 'Dr. Mamatha I.', designation: 'Associate Professor', role: 'faculty' },
  { facultyId: '0498', fullName: 'Ms. Megha Rani', designation: 'Assistant Professor (Senior)', role: 'faculty' },
  { facultyId: '0457', fullName: 'Dr. Vighnesh Shenoy', designation: 'Asst. Professor (Selection Grade)', role: 'faculty' },
  { facultyId: '0485', fullName: 'Dr. Ganesha Prasad', designation: 'Asst. Professor (Selection Grade)', role: 'faculty' },
  { facultyId: '0585', fullName: 'Dr. Vandana Bhat', designation: 'Associate Professor', role: 'faculty' },
  
  // Placeholder for the 5 coordinator accounts
  // { facultyId: 'COORD1', fullName: 'Coordinator One', designation: 'Club Coordinator', role: 'coordinator', club: 'Code Club' },
];

async function seedStaff() {
  console.log('Seeding staff members...');

  for (const person of facultyData) {
    const { facultyId, fullName, designation, role, club } = person;
    const email = `${facultyId.trim().toLowerCase().replace(/\s/g, '')}@aikya.internal`;
    const password = `${facultyId}@ml`;

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

      const userDoc = {
        uid: userRecord.uid,
        email: email,
        facultyId: facultyId,
        fullName: fullName,
        role: role,
        designation: designation,
        mustResetPassword: true,
        profileComplete: true,
      };

      if (club) userDoc.club = club;

      await admin.firestore().collection('users').doc(userRecord.uid).set(userDoc, { merge: true });
      console.log(`Provisioned ${facultyId} successfully.`);
    } catch (err) {
      console.error(`Error provisioning ${facultyId}:`, err);
    }
  }

  console.log('Seeding complete.');
  process.exit(0);
}

seedStaff();
