// Script de seed para demo "Country Living"
// Ejecuta pasos 1, 2, 3 y 6 del plan en una sola corrida.
// Pasos 4, 5, 7 requieren interacción del user (registrar cuentas + promover después).
//
// Uso:
//   1. gcloud auth application-default login --project=vecindario-app-a746b
//   2. cd tools && npm install firebase-admin
//   3. node seed_demo.js
//
// Idempotente en la medida de lo posible: si re-corres, sobreescribe docs con
// los mismos IDs donde sea relevante. La comunidad Country Living se crea con
// ID fijo "country-living" para poder re-seedear sin duplicar.

const admin = require('firebase-admin');

admin.initializeApp({
  projectId: 'vecindario-app-a746b',
});

const db = admin.firestore();
const auth = admin.auth();
const FieldValue = admin.firestore.FieldValue;
const Timestamp = admin.firestore.Timestamp;

const OLD_COMMUNITY_ID = 'Z4aU2ELZfPbTn1YMOu0g';
const NEW_COMMUNITY_ID = 'country-living';

const COMMUNITY_SUBCOLLECTIONS = [
  'posts', 'circulars', 'fines', 'bookings', 'amenities', 'pqrs',
  'finances', 'assemblies', 'account_statements', 'notifications',
  'services', 'stores', 'orders',
];

async function deleteCollection(ref, batchSize = 200) {
  const snap = await ref.limit(batchSize).get();
  if (snap.empty) return 0;
  const batch = db.batch();
  snap.docs.forEach(d => batch.delete(d.ref));
  await batch.commit();
  const rest = await deleteCollection(ref, batchSize);
  return snap.size + rest;
}

async function step1_wipeLasFlores() {
  console.log('\n=== Paso 1: Wipe Las Flores ===');
  const commRef = db.collection('communities').doc(OLD_COMMUNITY_ID);

  // Subcolecciones
  for (const col of COMMUNITY_SUBCOLLECTIONS) {
    const count = await deleteCollection(commRef.collection(col));
    if (count > 0) console.log(`  - Borrados ${count} docs de ${col}`);
  }

  // Posts/stores/orders en raíz que apunten a la comunidad
  for (const col of ['posts', 'stores', 'orders']) {
    const q = await db.collection(col).where('communityId', '==', OLD_COMMUNITY_ID).get();
    if (!q.empty) {
      const batch = db.batch();
      q.docs.forEach(d => batch.delete(d.ref));
      await batch.commit();
      console.log(`  - Borrados ${q.size} docs en /${col} (root) con communityId Las Flores`);
    }
  }

  // Doc raíz y subscription
  await commRef.delete().catch(() => {});
  await db.collection('subscriptions').doc(OLD_COMMUNITY_ID).delete().catch(() => {});

  // Users de esa comunidad (los dejamos sin communityId para no perder Auth huérfano)
  const usersQ = await db.collection('users').where('communityId', '==', OLD_COMMUNITY_ID).get();
  if (!usersQ.empty) {
    const batch = db.batch();
    usersQ.docs.forEach(d => batch.delete(d.ref));
    await batch.commit();
    console.log(`  - Borrados ${usersQ.size} docs de users con communityId Las Flores`);
  }

  console.log('  ✓ Las Flores wipeado');
}

async function step2_disableAuthUsers() {
  console.log('\n=== Paso 2: Deshabilitar Auth users ===');
  let count = 0;
  let nextPageToken;
  do {
    const result = await auth.listUsers(1000, nextPageToken);
    for (const u of result.users) {
      if (!u.disabled) {
        await auth.updateUser(u.uid, { disabled: true });
        count++;
        console.log(`  - Deshabilitado: ${u.email || u.uid}`);
      }
    }
    nextPageToken = result.pageToken;
  } while (nextPageToken);
  console.log(`  ✓ ${count} users deshabilitados`);
}

async function step3_createCountryLiving() {
  console.log('\n=== Paso 3: Crear Country Living ===');
  const commRef = db.collection('communities').doc(NEW_COMMUNITY_ID);
  await commRef.set({
    name: 'Country Living',
    address: 'Calle 127 #45-67',
    city: 'Bogotá',
    inviteCode: 'COUNTRY',
    memberCount: 10,
    plan: 'professional',
    active: true,
    adminUid: null,
    towers: 5,
    floorsPerTower: 18,
    unitsLayout: {
      T1: { floors: 18, unitsPerFloor: 4 },
      T2: { floors: 18, unitsPerFloor: 4 },
      T3: { floors: 18, unitsPerFloor: 4 },
      T4: { floors: 18, unitsPerFloor: 6 },
      T5: { floors: 18, unitsPerFloor: 6 },
    },
    totalUnits: 432,
    createdAt: FieldValue.serverTimestamp(),
  });

  const trialEnd = new Date();
  trialEnd.setDate(trialEnd.getDate() + 30);
  await db.collection('subscriptions').doc(NEW_COMMUNITY_ID).set({
    communityId: NEW_COMMUNITY_ID,
    plan: 'professional',
    status: 'trial',
    trialEndsAt: Timestamp.fromDate(trialEnd),
    features: ['pqrs', 'finances', 'amenities', 'circulars', 'fines'],
    createdAt: FieldValue.serverTimestamp(),
  });

  console.log(`  ✓ Community "${NEW_COMMUNITY_ID}" creada con código COUNTRY`);
}

async function step6_seedContent() {
  console.log('\n=== Paso 6: Seed de contenido ===');

  // 6a. Residentes de relleno (con UIDs fake "seed-*")
  const fakeResidents = [
    { id: 'seed-maria', displayName: 'María González', tower: '1', unit: '401' },
    { id: 'seed-luis', displayName: 'Luis Martínez', tower: '2', unit: '802' },
    { id: 'seed-ana', displayName: 'Ana Rodríguez', tower: '3', unit: '1501' },
    { id: 'seed-pedro', displayName: 'Pedro Castro', tower: '4', unit: '605' },
    { id: 'seed-sofia', displayName: 'Sofía Ramírez', tower: '5', unit: '1203' },
    { id: 'seed-diego', displayName: 'Diego Ortiz', tower: '1', unit: '1702' },
  ];
  for (const r of fakeResidents) {
    await db.collection('users').doc(r.id).set({
      id: r.id,
      email: `${r.id}@seed.demo`,
      displayName: r.displayName,
      role: 'resident',
      communityId: NEW_COMMUNITY_ID,
      verified: true,
      towerNumber: r.tower,
      unitNumber: r.unit,
      createdAt: FieldValue.serverTimestamp(),
    });
  }
  console.log(`  - 6 residentes relleno creados`);

  // 6b. Posts del feed
  const posts = [
    { authorUid: 'seed-admin', authorName: 'Administración', content: 'Bienvenidos al nuevo portal digital del conjunto. Aquí podrán ver circulares, reservar zonas, reportar PQRS y mucho más.', pinned: true },
    { authorUid: 'seed-admin', authorName: 'Administración', content: 'Asamblea ordinaria el 15 de mayo a las 7pm en el salón social. Por favor confirmar asistencia.', pinned: false },
    { authorUid: 'seed-maria', authorName: 'María González', content: 'Se extravió un gato gris en la torre 3. Responde al nombre de Milo. Contactar al apto 1501.', pinned: false },
    { authorUid: 'seed-luis', authorName: 'Luis Martínez', content: 'Vendo nevera LG de 400L en excelente estado, $800.000 negociables. Apto T2-802.', pinned: false },
    { authorUid: 'seed-admin', authorName: 'Administración', content: 'Recordatorio: este domingo 27 no hay recolección de basura. Guardarla hasta el lunes.', pinned: false },
    { authorUid: 'seed-sofia', authorName: 'Sofía Ramírez', content: 'Grupo de caminantes sale los sábados a las 6am desde portería. Todos bienvenidos 🚶‍♀️', pinned: false },
  ];
  for (const p of posts) {
    await db.collection('posts').add({
      ...p,
      communityId: NEW_COMMUNITY_ID,
      likes: [],
      commentsCount: 0,
      createdAt: FieldValue.serverTimestamp(),
    });
  }
  console.log(`  - 6 posts creados`);

  // 6c. Circulares
  const circulars = [
    { title: 'Mantenimiento de ascensores - Martes 28', content: 'El martes 28 de este mes de 8am a 12pm se realizará mantenimiento preventivo de los ascensores de las torres 1 y 2. Por favor usar las escaleras.', requiresAck: true },
    { title: 'Nueva tarifa administración 2026', content: 'A partir del 1 de junio la cuota de administración será de $380.000 mensuales para aptos de 4 alcobas y $320.000 para 3 alcobas. Aprobado en asamblea.', requiresAck: true },
    { title: 'Horarios zona húmeda verano', content: 'Piscina: 8am-8pm todos los días. Sauna: 10am-7pm. Turco: 10am-7pm. Menores de 12 años deben ir acompañados.', requiresAck: false },
  ];
  for (const c of circulars) {
    await db.collection('communities').doc(NEW_COMMUNITY_ID).collection('circulars').add({
      ...c,
      authorUid: 'seed-admin',
      authorName: 'Administración',
      readBy: [],
      ackBy: [],
      createdAt: FieldValue.serverTimestamp(),
    });
  }
  console.log(`  - 3 circulares creadas`);

  // 6d. Amenidades
  const amenities = [
    { name: 'Salón Social', description: 'Para eventos de hasta 50 personas. Incluye cocina y baños.', capacity: 50, hourlyRate: 0, deposit: 200000, openHour: 8, closeHour: 23, rules: 'No música después de las 11pm. Entregar limpio.' },
    { name: 'Gimnasio', description: 'Equipado con máquinas cardio y pesas.', capacity: 15, hourlyRate: 0, deposit: 0, openHour: 5, closeHour: 22, rules: 'Uso obligatorio de toalla. Limpiar equipos después de usar.' },
    { name: 'Piscina', description: 'Piscina de 25m con zona infantil.', capacity: 30, hourlyRate: 0, deposit: 0, openHour: 8, closeHour: 20, rules: 'Menores de 12 con acompañante. Uso de gorro obligatorio.' },
    { name: 'Zona BBQ', description: 'Asador con mesa para 20 personas. Vista al parque.', capacity: 20, hourlyRate: 50000, deposit: 100000, openHour: 10, closeHour: 22, rules: 'Traer utensilios. Llevar basura al shut.' },
  ];
  for (const a of amenities) {
    await db.collection('communities').doc(NEW_COMMUNITY_ID).collection('amenities').add({
      ...a,
      active: true,
      createdAt: FieldValue.serverTimestamp(),
    });
  }
  console.log(`  - 4 amenidades creadas`);

  // 6e. Finanzas (10 movimientos)
  const now = new Date();
  const thisMonth = new Date(now.getFullYear(), now.getMonth(), 15);
  const lastMonth = new Date(now.getFullYear(), now.getMonth() - 1, 15);
  const finances = [
    { type: 'income', category: 'administration', description: 'Administración abril 2026', amount: 18000000, date: lastMonth },
    { type: 'income', category: 'administration', description: 'Administración mayo 2026', amount: 18200000, date: thisMonth },
    { type: 'income', category: 'other', description: 'Parqueadero de visitantes', amount: 450000, date: thisMonth },
    { type: 'income', category: 'fines', description: 'Multa T2-802 - ruido', amount: 150000, date: thisMonth },
    { type: 'income', category: 'other', description: 'Aporte fondo de imprevistos', amount: 2000000, date: thisMonth },
    { type: 'expense', category: 'payroll', description: 'Nómina portería - abril', amount: 8500000, date: lastMonth },
    { type: 'expense', category: 'cleaning', description: 'Aseo y cafetería', amount: 3200000, date: thisMonth },
    { type: 'expense', category: 'maintenance', description: 'Mantenimiento ascensores', amount: 1800000, date: thisMonth },
    { type: 'expense', category: 'other', description: 'Papelería y oficina', amount: 180000, date: thisMonth },
    { type: 'expense', category: 'utilities', description: 'Servicios públicos áreas comunes', amount: 4500000, date: thisMonth },
  ];
  for (const f of finances) {
    await db.collection('communities').doc(NEW_COMMUNITY_ID).collection('finances').add({
      ...f,
      date: Timestamp.fromDate(f.date),
      createdAt: FieldValue.serverTimestamp(),
      authorUid: 'seed-admin',
    });
  }
  console.log(`  - 10 movimientos financieros creados`);

  // 6f. PQRS
  const pqrs = [
    { type: 'complaint', category: 'noise', description: 'Ruido excesivo en apto 1201 los fines de semana después de las 11pm. Afecta el descanso de vecinos aledaños.', status: 'inProgress', residentUid: 'seed-maria', residentName: 'María González', residentUnit: 'T1-401' },
    { type: 'petition', category: 'security', description: 'Solicito la instalación de cámaras adicionales en el parqueadero. Se han reportado rayones en vehículos.', status: 'received', residentUid: 'seed-luis', residentName: 'Luis Martínez', residentUnit: 'T2-802' },
    { type: 'question', category: 'maintenance', description: '¿Cuándo está programada la pintura de la fachada de la torre 4? Se ve descascarada.', status: 'resolved', response: 'Está programada para el mes de julio. Ya se firmó contrato con el proveedor.', residentUid: 'seed-pedro', residentName: 'Pedro Castro', residentUnit: 'T4-605' },
  ];
  for (const p of pqrs) {
    const data = {
      ...p,
      communityId: NEW_COMMUNITY_ID,
      createdAt: FieldValue.serverTimestamp(),
    };
    if (p.status === 'resolved') data.resolvedAt = FieldValue.serverTimestamp();
    await db.collection('communities').doc(NEW_COMMUNITY_ID).collection('pqrs').add(data);
  }
  console.log(`  - 3 PQRS creadas`);

  // 6g. Tiendas con items
  const stores = [
    {
      id: 'seed-store-dulceria',
      name: 'Dulcería Rosa',
      description: 'Postres caseros hechos con amor. Entrega el mismo día dentro del conjunto.',
      ownerUid: 'seed-rosa',
      ownerName: 'Doña Rosa',
      category: 'food',
      items: [
        { name: 'Brownie de chocolate', price: 8000, description: 'Brownie húmedo con chocolate belga' },
        { name: 'Cheesecake de fresa', price: 12000, description: 'Porción individual, base de galleta' },
        { name: 'Torta red velvet (porción)', price: 7000, description: 'Con frosting de queso crema' },
        { name: 'Galletas caja x12', price: 15000, description: 'Mixtas: chocolate, avena, mantequilla' },
      ],
    },
    {
      id: 'seed-store-mascotas',
      name: 'Mascotas del Conjunto',
      description: 'Todo para tu peludo sin salir del edificio.',
      ownerUid: 'seed-admin',
      ownerName: 'Carlos Pérez',
      category: 'pets',
      items: [
        { name: 'Concentrado perro 2kg', price: 45000, description: 'Ringo adulto, sabor carne' },
        { name: 'Arena para gato 5kg', price: 28000, description: 'Aglutinante, control de olores' },
        { name: 'Juguete mordedor', price: 15000, description: 'Caucho resistente, varios colores' },
      ],
    },
    {
      id: 'seed-store-market',
      name: 'Mini Market 24h',
      description: 'Productos básicos a toda hora. Domicilio gratis en el conjunto.',
      ownerUid: 'seed-admin',
      ownerName: 'Juan Gómez',
      category: 'grocery',
      items: [
        { name: 'Leche entera 1L', price: 5500, description: 'Alpina, larga vida' },
        { name: 'Huevos AA x30', price: 18000, description: 'Frescos del día' },
        { name: 'Pan tajado grande', price: 7000, description: 'Bimbo o equivalente' },
        { name: 'Gaseosa 1.5L', price: 6000, description: 'Coca-Cola / Postobón a elegir' },
      ],
    },
  ];
  for (const s of stores) {
    const { items, id, ...storeData } = s;
    await db.collection('stores').doc(id).set({
      ...storeData,
      communityId: NEW_COMMUNITY_ID,
      active: true,
      rating: 4.5 + Math.random() * 0.5,
      ratingCount: Math.floor(Math.random() * 20) + 5,
      createdAt: FieldValue.serverTimestamp(),
    });
    for (const [idx, item] of items.entries()) {
      await db.collection('stores').doc(id).collection('items').add({
        ...item,
        storeId: id,
        available: true,
        sortOrder: idx,
        createdAt: FieldValue.serverTimestamp(),
      });
    }
  }
  console.log(`  - 3 tiendas con ${stores.reduce((a, s) => a + s.items.length, 0)} items creadas`);

  console.log('  ✓ Seed completo');
}

async function main() {
  console.log('🚀 Seed Country Living - iniciando...\n');
  try {
    await step1_wipeLasFlores();
    await step2_disableAuthUsers();
    await step3_createCountryLiving();
    await step6_seedContent();
    console.log('\n✅ LISTO. Ahora registra las 4 cuentas en la app:');
    console.log('   - super@demo.com / demo1234 (Super Admin)');
    console.log('   - admin@demo.com / demo1234 (Admin Country Living)');
    console.log('   - vecino@demo.com / demo1234 → join con código COUNTRY');
    console.log('   - tienda@demo.com / demo1234 → join con código COUNTRY');
    console.log('\nDespués avísame en el chat para promover cada cuenta.');
    process.exit(0);
  } catch (err) {
    console.error('\n❌ ERROR:', err);
    process.exit(1);
  }
}

main();
