import 'dotenv/config';
import admin from 'firebase-admin';
import fs from 'fs';

// Look for service account dynamically or from env
let serviceAccount;
if (process.env.FIREBASE_SERVICE_ACCOUNT) {
  serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
} else if (fs.existsSync('./service-account.json')) {
  serviceAccount = JSON.parse(fs.readFileSync('./service-account.json', 'utf8'));
}

if (!admin.apps.length) {
  admin.initializeApp({
    credential: serviceAccount
      ? admin.credential.cert(serviceAccount)
      : admin.credential.applicationDefault(),
  });
}

const db = admin.firestore();

const seedData = {
  "23_regular": { yearOfStudy: 4, label: "Final Year" },
  "24_regular": { yearOfStudy: 3, label: "3rd Year" },
  "24_lateral_diploma": { yearOfStudy: 4, label: "Final Year" },
  "25_lateral_diploma": { yearOfStudy: 2, label: "2nd Year" }
};

async function seed() {
  console.log("Seeding academicBatchConfig...");
  const batch = db.batch();
  
  for (const [key, data] of Object.entries(seedData)) {
    const docRef = db.collection('academicBatchConfig').doc(key);
    batch.set(docRef, data, { merge: true });
  }

  try {
    await batch.commit();
    console.log("Seeding complete.");
    process.exit(0);
  } catch (err) {
    console.error("Error seeding config:", err);
    process.exit(1);
  }
}

seed();
