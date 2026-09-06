import express from 'express';
import admin from 'firebase-admin';
import parseUsn from '../utils/usnParser.js';

const router = express.Router();

router.put('/profile', async (req, res) => {
  try {
    // Basic auth check via Authorization header (Bearer token)
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    
    const idToken = authHeader.split('Bearer ')[1];
    let decodedToken;
    try {
      decodedToken = await admin.auth().verifyIdToken(idToken);
    } catch (e) {
      return res.status(401).json({ error: 'Unauthorized: Invalid token' });
    }
    
    const uid = decodedToken.uid;
    const {
      fullName,
      usn,
      phone,
      bio,
      githubUrl,
      linkedinUrl,
      instagramHandle,
      personalWebsite,
      twitterHandle,
      discordHandle,
      profilePictureUrl,
      flagForHodReview
    } = req.body;
    
    const parsedUsn = parseUsn(usn);
    
    if (!parsedUsn) {
      return res.status(400).json({ error: 'Invalid USN format' });
    }
    
    const db = admin.firestore();
    const configDoc = await db.collection('academicBatchConfig').doc(parsedUsn.configKey).get();
    
    let yearOfStudy = null;
    let batch = null;
    let status = null;
    let profileComplete = true; // Assume true on success

    if (configDoc.exists) {
      const config = configDoc.data();
      yearOfStudy = config.yearOfStudy?.toString();
      batch = config.label; // or whatever batch field corresponds to. Wait, batch is batch year or label?
      // The frontend displayed `$_yearOfStudy Year, $_batch`. 
      // E.g., '4 Year, Final Year' -> label: "Final Year", yearOfStudy: 4.
      // So batch = "Batch of " + (2000 + parseInt(admissionYY) + 4) or similar? 
      // The prompt says: "label: 'Final Year' | '3rd Year'"
      batch = config.label;
    } else {
      status = 'pending_batch_review';
    }
    
    const updateData = {
      fullName: fullName?.trim() || '',
      usn: parsedUsn.usn,
      phone: phone || null,
      yearOfStudy: yearOfStudy,
      batch: batch,
      status: status,
      bio: bio?.trim() || null,
      githubUrl: githubUrl?.trim() || null,
      linkedinUrl: linkedinUrl?.trim() || null,
      instagramHandle: instagramHandle?.trim() || null,
      personalWebsite: personalWebsite?.trim() || null,
      twitterHandle: twitterHandle?.trim() || null,
      discordHandle: discordHandle?.trim() || null,
      profilePictureUrl: profilePictureUrl || null,
      profileComplete: true,
    };
    
    if (flagForHodReview) {
      updateData.flagForHodReview = true;
    }

    // Filter out undefined values
    Object.keys(updateData).forEach(key => updateData[key] === undefined && delete updateData[key]);

    await db.collection('users').doc(uid).set(updateData, { merge: true });

    return res.json({ success: true, user: updateData });
  } catch (error) {
    console.error('Error updating profile:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
