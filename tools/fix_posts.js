// Fix: mueve los posts de /posts (root) a /communities/country-living/posts (subcollection)
const admin = require('firebase-admin');
admin.initializeApp({ projectId: 'vecindario-app-a746b' });
const db = admin.firestore();
const COMMUNITY_ID = 'country-living';

async function main() {
  console.log('🔧 Moviendo posts a subcolección correcta...');

  // Borrar posts mal sembrados en root (los que tienen communityId = country-living)
  const rootPosts = await db.collection('posts')
    .where('communityId', '==', COMMUNITY_ID)
    .get();
  for (const doc of rootPosts.docs) {
    const data = doc.data();
    // Crear en subcolección correcta
    await db.collection('communities').doc(COMMUNITY_ID).collection('posts').add(data);
    // Borrar del root
    await doc.ref.delete();
  }
  console.log(`  ✓ ${rootPosts.size} posts movidos a /communities/${COMMUNITY_ID}/posts`);

  // Verificación
  const sub = await db.collection('communities').doc(COMMUNITY_ID).collection('posts').count().get();
  console.log(`  ✓ Total en subcolección ahora: ${sub.data().count}`);
  process.exit(0);
}

main().catch(e => { console.error('❌', e); process.exit(1); });
