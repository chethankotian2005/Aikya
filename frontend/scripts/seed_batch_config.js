const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

// Initialize with service account key
const serviceAccount = require('../../backend/service-account.json');

initializeApp({
  credential: cert(serviceAccount),
  projectId: 'aikya-platform',
});

const db = getFirestore();

const batchConfigs = [
  // Alumni (graduated)
  { key: '20_regular',         yearOfStudy: 4, label: 'Alumni',      graduated: true },
  { key: '20_lateral_diploma', yearOfStudy: 4, label: 'Alumni',      graduated: true },
  { key: '21_regular',         yearOfStudy: 4, label: 'Alumni',      graduated: true },
  { key: '21_lateral_diploma', yearOfStudy: 4, label: 'Alumni',      graduated: true },
  { key: '22_regular',         yearOfStudy: 4, label: 'Alumni',      graduated: true },
  { key: '22_lateral_diploma', yearOfStudy: 4, label: 'Alumni',      graduated: true },
  // Current students (2026-27 academic year)
  { key: '23_regular',         yearOfStudy: 4, label: 'Final Year',  graduated: false },
  { key: '23_lateral_diploma', yearOfStudy: 4, label: 'Final Year',  graduated: false },
  { key: '24_regular',         yearOfStudy: 3, label: '3rd Year',    graduated: false },
  { key: '24_lateral_diploma', yearOfStudy: 3, label: '3rd Year',    graduated: false },
  { key: '25_regular',         yearOfStudy: 2, label: '2nd Year',    graduated: false },
  { key: '25_lateral_diploma', yearOfStudy: 2, label: '2nd Year',    graduated: false },
  { key: '26_regular',         yearOfStudy: 1, label: '1st Year',    graduated: false },
];

async function seed() {
  const batch = db.batch();
  
  for (const config of batchConfigs) {
    const docRef = db.collection('academicBatchConfig').doc(config.key);
    batch.set(docRef, {
      yearOfStudy: config.yearOfStudy,
      label: config.label,
      graduated: config.graduated,
    });
  }
  
  await batch.commit();
  console.log(`✅ Seeded ${batchConfigs.length} academicBatchConfig documents.`);
  process.exit(0);
}

seed().catch(err => {
  console.error('❌ Seeding failed:', err);
  process.exit(1);
});
