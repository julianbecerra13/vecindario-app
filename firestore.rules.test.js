const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');
const {doc, getDoc, setDoc, updateDoc, Timestamp, serverTimestamp, writeBatch} = require('firebase/firestore');
const fs = require('fs');

let testEnv;

const user = (overrides = {}) => ({
  displayName: 'Residente', email: 'resident@example.com', phone: '3000000000',
  photoURL: null, communityId: 'community-a', communityRole: 'resident',
  estrato: 3, verified: true, tower: '1', apartment: '101',
  createdAt: Timestamp.now(), ...overrides,
});

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'vecindario-app-a746b',
    firestore: {rules: fs.readFileSync('firestore.rules', 'utf8')},
  });
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await Promise.all([
      setDoc(doc(db, 'users/resident-a'), user()),
      setDoc(doc(db, 'users/resident-a2'), user({email: 'other@example.com'})),
      setDoc(doc(db, 'users/resident-b'), user({communityId: 'community-b'})),
      setDoc(doc(db, 'users/admin-a'), user({
        displayName: 'Admin A', email: 'admin@example.com', communityRole: 'admin',
      })),
      setDoc(doc(db, 'users/super-admin'), user({
        communityId: null, communityRole: 'resident', platformRole: 'super_admin',
      })),
      setDoc(doc(db, 'users/unjoined'), user({
        email: 'unjoined@example.com', communityId: null, verified: false,
      })),
      setDoc(doc(db, 'invite_codes/CEDR26'), {
        communityId: 'community-a', unitType: 'apartment',
      }),
      setDoc(doc(db, 'communities/community-a/fines/fine-a'), {
        residentUid: 'resident-a', status: 'notified', defenseText: null, amount: 100000,
      }),
      setDoc(doc(db, 'communities/community-a/pqrs/pqrs-a'), {
        residentUid: 'resident-a', description: 'Solicitud', status: 'received', assignedTo: null,
      }),
      setDoc(doc(db, 'stores/store-a'), {
        ownerUid: 'resident-a', communityId: 'community-a', name: 'Tienda A',
        description: '', imageURL: null, deliveryTime: '15-25 min', minOrder: 10000,
        active: true, rating: 0, orderCount: 0, createdAt: Timestamp.now(),
      }),
      setDoc(doc(db, 'orders/order-pending'), {
        buyerUid: 'resident-a', storeOwnerUid: 'resident-a2',
        communityId: 'community-a', status: 'pending', createdAt: Timestamp.now(),
      }),
      setDoc(doc(db, 'orders/order-delivered'), {
        buyerUid: 'resident-a', storeOwnerUid: 'resident-a2',
        communityId: 'community-a', status: 'delivered', createdAt: Timestamp.now(),
      }),
    ]);
  });
});

afterAll(async () => testEnv.cleanup());

describe('control de acceso QR', () => {
  const path = 'communities/community-a/access_tokens/token-a';
  const card = () => ({residentUid: 'resident-a', name: 'Residente',
    unit: 'Torre 1 - Apto 101', createdAt: serverTimestamp(),
    expiresAt: Timestamp.fromMillis(Date.now() + 240000), used: false});

  test('emite QR propio y rechaza identidad o apartamento falsificados', async () => {
    const db = testEnv.authenticatedContext('resident-a').firestore();
    await assertSucceeds(setDoc(doc(db, path), card()));
    await assertFails(setDoc(doc(db, path + '-fake'), {...card(), unit: 'Otro apartamento'}));
    await assertFails(setDoc(doc(db, path + '-other'), {...card(), residentUid: 'resident-a2'}));
  });

  test('no permite autoasignar operario ni alterar estado de administración', async () => {
    const db = testEnv.authenticatedContext('resident-a').firestore();
    await assertFails(setDoc(doc(db, 'communities/community-a/access_staff/resident-a'), {active: true}));
    await assertFails(setDoc(doc(db, 'communities/community-a/access_status/resident-a'), {status: 'current'}));
  });

  test('operario del conjunto registra ingreso atómico y no reutiliza QR', async () => {
    await assertSucceeds(setDoc(doc(testEnv.authenticatedContext('resident-a').firestore(), path), card()));
    const admin = testEnv.authenticatedContext('admin-a').firestore();
    await assertSucceeds(setDoc(doc(admin, 'communities/community-a/access_staff/resident-a2'), {active: true, updatedAt: serverTimestamp()}));
    const other = testEnv.authenticatedContext('resident-b').firestore();
    await assertFails(getDoc(doc(other, path)));
    const db = testEnv.authenticatedContext('resident-a2').firestore();
    await assertSucceeds(getDoc(doc(db, path)));
    await assertFails(updateDoc(doc(db, path), {used: true}));
    const batch = writeBatch(db);
    batch.update(doc(db, path), {used: true});
    batch.set(doc(db, 'communities/community-a/access_logs/token-a'), {
      residentUid: 'resident-a', operatorUid: 'resident-a2', zone: 'Piscina',
      residents: 1, visitors: 2, createdAt: serverTimestamp(),
    });
    await assertSucceeds(batch.commit());
    await assertFails(updateDoc(doc(db, path), {used: true}));
  });
});

describe('users', () => {
  test('permite crear solamente un perfil residente no verificado', async () => {
    const db = testEnv.authenticatedContext('new-user').firestore();
    await assertSucceeds(setDoc(doc(db, 'users/new-user'), user({
      communityId: null, verified: false,
    })));
  });

  test.each([
    {verified: true},
    {communityRole: 'admin'},
    {platformRole: 'super_admin'},
  ])('impide privilegios durante el registro: %o', async (override) => {
    const db = testEnv.authenticatedContext('attacker').firestore();
    await assertFails(setDoc(doc(db, 'users/attacker'), user({
      communityId: null, verified: false, ...override,
    })));
  });

  test('impide cambiar roles o verificación después del registro', async () => {
    const db = testEnv.authenticatedContext('resident-a').firestore();
    await assertFails(updateDoc(doc(db, 'users/resident-a'), {platformRole: 'super_admin'}));
    await assertFails(updateDoc(doc(db, 'users/resident-a'), {communityRole: 'admin'}));
    await assertFails(updateDoc(doc(db, 'users/resident-a'), {verified: false}));
  });

  test('aísla perfiles entre comunidades', async () => {
    const db = testEnv.authenticatedContext('resident-a').firestore();
    await assertFails(getDoc(doc(db, 'users/resident-a2')));
    await assertFails(getDoc(doc(db, 'users/resident-b')));
  });

  test('permite unirse una sola vez desde un perfil no verificado', async () => {
    const db = testEnv.authenticatedContext('unjoined').firestore();
    await assertSucceeds(updateDoc(doc(db, 'users/unjoined'), {
      communityId: 'community-a', tower: '1', apartment: '202', verified: false,
    }));
    await assertFails(updateDoc(doc(db, 'users/unjoined'), {
      communityId: 'community-b',
    }));
  });
});

describe('códigos de invitación', () => {
  test('usuario autenticado puede leer un código exacto', async () => {
    const db = testEnv.authenticatedContext('unjoined').firestore();
    await assertSucceeds(getDoc(doc(db, 'invite_codes/CEDR26')));
  });

  test('usuario anónimo no puede leer códigos', async () => {
    const db = testEnv.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(db, 'invite_codes/CEDR26')));
  });
});

describe('multas y PQRS', () => {
  test('residente solo puede presentar descargos sin escoger otro estado', async () => {
    const db = testEnv.authenticatedContext('resident-a').firestore();
    const fineRef = doc(db, 'communities/community-a/fines/fine-a');
    await assertSucceeds(updateDoc(fineRef, {
      defenseText: 'Presento mi descargo', status: 'defense',
    }));
    await assertFails(updateDoc(fineRef, {status: 'paid'}));
  });

  test('residente no puede autoasignar ni resolver su PQRS', async () => {
    const db = testEnv.authenticatedContext('resident-a').firestore();
    const pqrsRef = doc(db, 'communities/community-a/pqrs/pqrs-a');
    await assertFails(updateDoc(pqrsRef, {status: 'resolved'}));
    await assertFails(updateDoc(pqrsRef, {assignedTo: 'resident-a'}));
  });
});

describe('tiendas', () => {
  test('impide crear una tienda para otro propietario o comunidad', async () => {
    const db = testEnv.authenticatedContext('resident-a').firestore();
    const base = {
      ownerUid: 'resident-a', communityId: 'community-a', name: 'Nueva tienda',
      description: '', imageURL: null, deliveryTime: '15-25 min', minOrder: 10000,
      active: true, rating: 0, orderCount: 0, createdAt: Timestamp.now(),
    };
    await assertSucceeds(setDoc(doc(db, 'stores/valid-store'), base));
    await assertFails(setDoc(doc(db, 'stores/forged-owner'), {...base, ownerUid: 'resident-b'}));
    await assertFails(setDoc(doc(db, 'stores/other-community'), {...base, communityId: 'community-b'}));
  });

  test('propietario no puede transferir la tienda desde el cliente', async () => {
    const db = testEnv.authenticatedContext('resident-a').firestore();
    await assertFails(updateDoc(doc(db, 'stores/store-a'), {ownerUid: 'resident-b'}));
  });
});

describe('pedidos', () => {
  test('crea pedido solo con propietario y comunidad reales de la tienda', async () => {
    const db = testEnv.authenticatedContext('resident-a').firestore();
    const order = {buyerUid: 'resident-a', storeId: 'store-a',
      storeOwnerUid: 'resident-a', communityId: 'community-a', status: 'pending'};
    await assertSucceeds(setDoc(doc(db, 'orders/order-valid'), order));
    await assertFails(setDoc(doc(db, 'orders/order-forged'), {...order, storeOwnerUid: 'resident-b'}));
    await assertFails(setDoc(doc(db, 'orders/order-cross-community'), {...order, communityId: 'community-b'}));
  });

  test('comprador puede cancelar únicamente antes de que vaya en camino', async () => {
    const db = testEnv.authenticatedContext('resident-a').firestore();
    await assertSucceeds(updateDoc(doc(db, 'orders/order-pending'), {
      status: 'cancelled',
    }));
    await assertFails(updateDoc(doc(db, 'orders/order-delivered'), {
      status: 'cancelled',
    }));
  });

  test('comprador no puede cambiar el pedido ni marcarlo entregado', async () => {
    const db = testEnv.authenticatedContext('resident-a').firestore();
    await assertFails(updateDoc(doc(db, 'orders/order-pending'), {
      status: 'delivered',
    }));
    await assertFails(updateDoc(doc(db, 'orders/order-pending'), {
      total: 1,
    }));
  });
});

describe('reservas', () => {
  test('residente solo crea una reserva cuyo documento coincide con slotKey', async () => {
    const db = testEnv.authenticatedContext('resident-a').firestore();
    const booking = {residentUid: 'resident-a', amenityId: 'pool',
      slotKey: 'pool_20261001', status: 'confirmed', createdAt: serverTimestamp()};
    await assertSucceeds(setDoc(doc(db,
      'communities/community-a/bookings/pool_20261001'), booking));
    await assertFails(setDoc(doc(db,
      'communities/community-a/bookings/otro'), booking));
    await assertFails(setDoc(doc(db,
      'communities/community-a/bookings/pool_20261002'),
      {...booking, slotKey: 'pool_20261002', residentUid: 'resident-a2'}));
  });
});

describe('acceso anónimo', () => {
  test('no permite leer perfiles', async () => {
    const db = testEnv.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(db, 'users/resident-a')));
  });
});
