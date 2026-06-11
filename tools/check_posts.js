const admin = require('firebase-admin');
admin.initializeApp({ projectId: 'vecindario-app-a746b' });
const db = admin.firestore();

async function main() {
  const snap = await db.collection('communities').doc('country-living').collection('posts')
    .orderBy('pinned', 'desc').orderBy('createdAt', 'desc').limit(10).get();
  console.log(`📄 ${snap.size} posts en /communities/country-living/posts:`);
  for (const doc of snap.docs) {
    const d = doc.data();
    console.log(`  - ${doc.id}: pinned=${d.pinned}, text=${d.text ? 'SI' : 'NO'}, content=${d.content ? 'SI' : 'NO'}, authorName=${d.authorName}`);
  }
  process.exit(0);
}
main().catch(e => { console.error(e); process.exit(1); });
