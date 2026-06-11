// Script para promover una cuenta Auth recién registrada.
// Uso:
//   node promote_account.js super@demo.com super_admin
//   node promote_account.js admin@demo.com admin
//   node promote_account.js vecino@demo.com resident
//   node promote_account.js tienda@demo.com store_owner
//
// Requiere que la cuenta ya esté registrada en la app.

const admin = require('firebase-admin');
admin.initializeApp({ projectId: 'vecindario-app-a746b' });

const db = admin.firestore();
const auth = admin.auth();
const COMMUNITY_ID = 'country-living';

async function main() {
  const email = process.argv[2];
  const role = process.argv[3];
  if (!email || !role) {
    console.error('Uso: node promote_account.js <email> <role>');
    console.error('  roles: super_admin | admin | resident | store_owner');
    process.exit(1);
  }

  let user;
  try {
    user = await auth.getUserByEmail(email);
  } catch (e) {
    console.error(`❌ No existe cuenta Auth con email ${email}`);
    process.exit(1);
  }

  if (user.disabled) {
    await auth.updateUser(user.uid, { disabled: false });
    console.log(`  - Re-habilitado (estaba disabled)`);
  }

  const userRef = db.collection('users').doc(user.uid);
  const snap = await userRef.get();
  const update = { verified: true, role };

  if (role === 'super_admin') {
    // Sin comunidad
    update.communityId = null;
  } else if (role === 'admin') {
    update.communityId = COMMUNITY_ID;
    update.towerNumber = '1';
    update.unitNumber = '101';
    // Setear adminUid en la community
    await db.collection('communities').doc(COMMUNITY_ID).update({ adminUid: user.uid });
    console.log(`  - Community.adminUid seteado a ${user.uid}`);
  } else if (role === 'resident') {
    // communityId ya debería estar por el flujo de join
    update.communityId = COMMUNITY_ID;
  } else if (role === 'store_owner') {
    update.communityId = COMMUNITY_ID;
    update.towerNumber = '1';
    update.unitNumber = '501';
  } else {
    console.error(`❌ Role inválido: ${role}`);
    process.exit(1);
  }

  if (!snap.exists) {
    // Si el doc no existe, crearlo con data base
    update.id = user.uid;
    update.email = user.email;
    update.displayName = user.displayName || email.split('@')[0];
    update.createdAt = admin.firestore.FieldValue.serverTimestamp();
    await userRef.set(update);
    console.log(`  - Doc creado en users/${user.uid}`);
  } else {
    await userRef.update(update);
    console.log(`  - Doc actualizado en users/${user.uid}`);
  }

  console.log(`✅ ${email} promovido a ${role}`);
  process.exit(0);
}

main().catch(err => {
  console.error('❌ ERROR:', err);
  process.exit(1);
});
