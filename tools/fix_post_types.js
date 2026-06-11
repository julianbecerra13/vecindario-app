const admin = require('firebase-admin');
admin.initializeApp({ projectId: 'vecindario-app-a746b' });
const db = admin.firestore();

async function main() {
  const snap = await db.collection('communities').doc('country-living').collection('posts').get();
  for (const doc of snap.docs) {
    const d = doc.data();
    const update = {};
    if (Array.isArray(d.likes)) {
      update.likes = d.likes.length;
      update.likedBy = d.likes;
    }
    if (d.commentsCount !== undefined && d.commentCount === undefined) {
      update.commentCount = d.commentsCount;
      update.commentsCount = admin.firestore.FieldValue.delete();
    }
    if (Object.keys(update).length > 0) {
      await doc.ref.update(update);
      console.log(`  ✓ ${doc.id}: ${Object.keys(update).join(', ')}`);
    }
  }
  console.log('✅ Listo');
  process.exit(0);
}
main().catch(e => { console.error(e); process.exit(1); });
