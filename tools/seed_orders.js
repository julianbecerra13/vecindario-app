const admin = require('firebase-admin');
admin.initializeApp({ projectId: 'vecindario-app-a746b' });
const db = admin.firestore();
const auth = admin.auth();
const FieldValue = admin.firestore.FieldValue;
const Timestamp = admin.firestore.Timestamp;

async function main() {
  console.log('🛒 Seed de pedidos para Dulcería Rosa...');

  // 1. Obtener UID de tienda@demo.com
  const tiendaUser = await auth.getUserByEmail('tienda@demo.com');
  const tiendaUid = tiendaUser.uid;
  const vecinoUser = await auth.getUserByEmail('vecino@demo.com');
  const vecinoUid = vecinoUser.uid;
  console.log(`  tienda uid: ${tiendaUid}`);
  console.log(`  vecino uid: ${vecinoUid}`);

  // 2. Update ownerUid de Dulcería Rosa al real
  await db.collection('stores').doc('seed-store-dulceria').update({
    ownerUid: tiendaUid,
  });
  console.log(`  ✓ Dulcería Rosa.ownerUid actualizado`);

  // 3. Crear 3 pedidos de ejemplo
  const storeId = 'seed-store-dulceria';
  const storeName = 'Dulcería Rosa';

  const now = Date.now();
  const orders = [
    {
      status: 'pending',
      createdAt: Timestamp.fromDate(new Date(now - 1000 * 60 * 15)), // 15 min atrás
      buyerUid: vecinoUid,
      buyerName: 'Carlos Vecino',
      buyerApartment: 'T2 - 1201',
      items: [
        { name: 'Brownie de chocolate', price: 8000, quantity: 3 },
        { name: 'Galletas caja x12', price: 15000, quantity: 1 },
      ],
      subtotal: 39000,
      serviceFee: 350,
      total: 39350,
      paymentMethod: 'cash',
      note: 'Entregar después de las 5pm',
    },
    {
      status: 'pending',
      createdAt: Timestamp.fromDate(new Date(now - 1000 * 60 * 45)), // 45 min
      buyerUid: 'seed-maria',
      buyerName: 'María González',
      buyerApartment: 'T1 - 401',
      items: [
        { name: 'Cheesecake de fresa', price: 12000, quantity: 2 },
      ],
      subtotal: 24000,
      serviceFee: 350,
      total: 24350,
      paymentMethod: 'cash',
    },
    {
      status: 'delivered',
      createdAt: Timestamp.fromDate(new Date(now - 1000 * 60 * 60 * 24 * 2)), // hace 2 días
      deliveredAt: Timestamp.fromDate(new Date(now - 1000 * 60 * 60 * 24 * 2 + 1000 * 60 * 40)),
      confirmedAt: Timestamp.fromDate(new Date(now - 1000 * 60 * 60 * 24 * 2 + 1000 * 60 * 5)),
      buyerUid: 'seed-luis',
      buyerName: 'Luis Martínez',
      buyerApartment: 'T2 - 802',
      items: [
        { name: 'Torta red velvet (porción)', price: 7000, quantity: 4 },
        { name: 'Brownie de chocolate', price: 8000, quantity: 2 },
      ],
      subtotal: 44000,
      serviceFee: 350,
      total: 44350,
      paymentMethod: 'cash',
    },
    {
      status: 'confirmed',
      createdAt: Timestamp.fromDate(new Date(now - 1000 * 60 * 5)), // 5 min
      confirmedAt: Timestamp.fromDate(new Date(now - 1000 * 60 * 2)),
      buyerUid: 'seed-sofia',
      buyerName: 'Sofía Ramírez',
      buyerApartment: 'T5 - 1203',
      items: [
        { name: 'Galletas caja x12', price: 15000, quantity: 2 },
      ],
      subtotal: 30000,
      serviceFee: 350,
      total: 30350,
      paymentMethod: 'cash',
      note: 'Sin nueces por favor (alergia)',
    },
  ];

  for (const o of orders) {
    await db.collection('orders').add({
      ...o,
      storeId,
      storeName,
      storeOwnerUid: tiendaUid,
    });
  }
  console.log(`  ✓ ${orders.length} pedidos creados`);
  console.log('\n✅ Listo. Refresh el panel de tienda.');
  process.exit(0);
}

main().catch(e => { console.error('❌', e); process.exit(1); });
