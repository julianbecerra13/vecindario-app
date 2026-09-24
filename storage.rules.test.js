const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');
const {doc, setDoc} = require('firebase/firestore');
const {ref, uploadBytes, getBytes, deleteObject} = require('firebase/storage');
const fs = require('fs');

let testEnv;
const image = new Uint8Array([0xff, 0xd8, 0xff, 0xd9]);
const metadata = {contentType: 'image/jpeg'};

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'vecindario-app-a746b',
    firestore: {rules: fs.readFileSync('firestore.rules', 'utf8')},
    storage: {rules: fs.readFileSync('storage.rules', 'utf8')},
  });
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.clearStorage();
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await Promise.all([
      setDoc(doc(db, 'users/resident-a'), {
        communityId: 'community-a', communityRole: 'resident', verified: true,
      }),
      setDoc(doc(db, 'users/resident-b'), {
        communityId: 'community-b', communityRole: 'resident', verified: true,
      }),
      setDoc(doc(db, 'users/admin-a'), {
        communityId: 'community-a', communityRole: 'admin', verified: true,
      }),
      setDoc(doc(db, 'stores/store-a'), {
        ownerUid: 'resident-a', communityId: 'community-a',
      }),
      setDoc(doc(db, 'communities/community-a/posts/post-a'), {
        authorUid: 'resident-a',
      }),
    ]);
  });
});

afterAll(async () => testEnv.cleanup());

test('usuario solo puede escribir su propia foto de perfil', async () => {
  const storage = testEnv.authenticatedContext('resident-a').storage();
  await assertSucceeds(uploadBytes(ref(storage, 'users/resident-a/profile.jpg'), image, metadata));
  await assertFails(uploadBytes(ref(storage, 'users/resident-b/profile.jpg'), image, metadata));
});

test('rechaza contenido no permitido y archivos demasiado grandes', async () => {
  const storage = testEnv.authenticatedContext('resident-a').storage();
  await assertFails(uploadBytes(
    ref(storage, 'users/resident-a/profile.jpg'), image, {contentType: 'text/html'},
  ));
  await assertFails(uploadBytes(
    ref(storage, 'users/resident-a/profile.jpg'), new Uint8Array(5 * 1024 * 1024 + 1), metadata,
  ));
});

test('solo el dueño puede escribir imágenes de su tienda', async () => {
  const ownerStorage = testEnv.authenticatedContext('resident-a').storage();
  const outsiderStorage = testEnv.authenticatedContext('resident-b').storage();
  await assertSucceeds(uploadBytes(ref(ownerStorage, 'stores/store-a/logo.jpg'), image, metadata));
  await assertFails(uploadBytes(ref(outsiderStorage, 'stores/store-a/logo.jpg'), image, metadata));
});

test('aísla lectura de tiendas entre comunidades', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await uploadBytes(ref(context.storage(), 'stores/store-a/logo.jpg'), image, metadata);
  });
  const sameCommunity = testEnv.authenticatedContext('resident-a').storage();
  const otherCommunity = testEnv.authenticatedContext('resident-b').storage();
  await assertSucceeds(getBytes(ref(sameCommunity, 'stores/store-a/logo.jpg')));
  await assertFails(getBytes(ref(otherCommunity, 'stores/store-a/logo.jpg')));
});

test('autor puede escribir su post y otro residente no', async () => {
  const authorStorage = testEnv.authenticatedContext('resident-a').storage();
  const outsiderStorage = testEnv.authenticatedContext('resident-b').storage();
  const path = 'communities/community-a/posts/post-a/image.jpg';
  await assertSucceeds(uploadBytes(ref(authorStorage, path), image, metadata));
  await assertFails(uploadBytes(ref(outsiderStorage, path), image, metadata));
  await assertSucceeds(deleteObject(ref(authorStorage, path)));
});
