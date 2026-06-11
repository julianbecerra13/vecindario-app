const admin = require('firebase-admin');
admin.initializeApp({ projectId: 'vecindario-app-a746b' });
const db = admin.firestore();

async function main() {
  const snap = await db.collection('communities').doc('country-living').collection('posts').get();
  for (const doc of snap.docs) {
    const d = doc.data();
    if (d.content && !d.text) {
      await doc.ref.update({ text: d.content, content: admin.firestore.FieldValue.delete() });
      console.log(`  ✓ ${doc.id}: renombrado content → text`);
    }
  }
  console.log('✅ Listo');
  process.exit(0);
}
main().catch(e => { console.error(e); process.exit(1); });
