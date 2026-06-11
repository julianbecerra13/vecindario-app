// Crea las 4 cuentas Auth + docs Firestore con roles listos.
// Reemplaza el registro manual en la app + promoción posterior.
//
// Uso: node create_accounts.js

const admin = require('firebase-admin');
admin.initializeApp({ projectId: 'vecindario-app-a746b' });

const db = admin.firestore();
const auth = admin.auth();
const FieldValue = admin.firestore.FieldValue;
const COMMUNITY_ID = 'country-living';

const ACCOUNTS = [
  {
    email: 'super@demo.com',
    password: 'demo1234',
    displayName: 'Super Admin',
    role: 'super_admin',
    communityId: null,
    towerNumber: null,
    unitNumber: null,
  },
  {
    email: 'admin@demo.com',
    password: 'demo1234',
    displayName: 'Admin Country',
    role: 'admin',
    communityId: COMMUNITY_ID,
    towerNumber: '1',
    unitNumber: '101',
  },
  {
    email: 'vecino@demo.com',
    password: 'demo1234',
    displayName: 'Carlos Vecino',
    role: 'resident',
    communityId: COMMUNITY_ID,
    towerNumber: '2',
    unitNumber: '1201',
  },
  {
    email: 'tienda@demo.com',
    password: 'demo1234',
    displayName: 'Doña Rosa',
    role: 'store_owner',
    communityId: COMMUNITY_ID,
    towerNumber: '1',
    unitNumber: '501',
  },
];

async function createOne(acc) {
  console.log(`\n--- ${acc.email} ---`);

  // Borrar si existe (para re-corridas idempotentes)
  try {
    const existing = await auth.getUserByEmail(acc.email);
    await auth.deleteUser(existing.uid);
    await db.collection('users').doc(existing.uid).delete().catch(() => {});
    console.log(`  - Cuenta previa borrada (${existing.uid})`);
  } catch (e) {
    // no existía, seguir
  }

  // Crear Auth user
  const user = await auth.createUser({
    email: acc.email,
    password: acc.password,
    displayName: acc.displayName,
    emailVerified: true,
    disabled: false,
  });
  console.log(`  - Auth creado: ${user.uid}`);

  // Crear doc Firestore
  const docData = {
    id: user.uid,
    email: acc.email,
    displayName: acc.displayName,
    role: acc.role,
    communityId: acc.communityId,
    verified: true,
    createdAt: FieldValue.serverTimestamp(),
  };
  if (acc.towerNumber) docData.towerNumber = acc.towerNumber;
  if (acc.unitNumber) docData.unitNumber = acc.unitNumber;

  await db.collection('users').doc(user.uid).set(docData);
  console.log(`  - Doc Firestore creado (role=${acc.role}, verified=true)`);

  // Si es admin, setear adminUid en la comunidad
  if (acc.role === 'admin') {
    await db.collection('communities').doc(COMMUNITY_ID).update({ adminUid: user.uid });
    console.log(`  - communities/${COMMUNITY_ID}.adminUid = ${user.uid}`);
  }

  return user.uid;
}

async function main() {
  console.log('🚀 Creando 4 cuentas de demo...');
  const results = [];
  for (const acc of ACCOUNTS) {
    const uid = await createOne(acc);
    results.push({ ...acc, uid });
  }

  console.log('\n✅ 4 cuentas listas:\n');
  for (const r of results) {
    console.log(`   ${r.email.padEnd(20)} / demo1234  [${r.role}]`);
  }
  console.log('\nEl user puede loguearse directamente, no necesita registrarse ni join-community.');
  process.exit(0);
}

main().catch(err => {
  console.error('❌ ERROR:', err);
  process.exit(1);
});
