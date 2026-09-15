/**
 * One-time backfill: sets `status: 'approved'` on every existing event that
 * has no `status` field, before firestore.rules starts gating read access
 * on that field. Without this, every event created before the HOD-approval
 * feature would silently become invisible to everyone but its creator and
 * the HOD the moment the new rules deploy.
 *
 * Run once: node scripts/backfill_event_status.js
 */
import 'dotenv/config';
import admin from 'firebase-admin';

const serviceAccount = process.env.FIREBASE_SERVICE_ACCOUNT
  ? JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT)
  : undefined;

admin.initializeApp({
  credential: serviceAccount
    ? admin.credential.cert(serviceAccount)
    : admin.credential.applicationDefault(),
});

async function backfill() {
  const db = admin.firestore();
  const snap = await db.collection('events').get();

  const toUpdate = snap.docs.filter((doc) => doc.data().status === undefined);
  if (toUpdate.length === 0) {
    console.log('No events need backfilling.');
    return;
  }

  const batch = db.batch();
  for (const doc of toUpdate) {
    batch.update(doc.ref, { status: 'approved' });
  }
  await batch.commit();
  console.log(`Backfilled status: 'approved' on ${toUpdate.length} of ${snap.size} event(s).`);
}

backfill()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error('Backfill failed:', err);
    process.exit(1);
  });
