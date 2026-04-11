/**
 * Seed Firestore — campos corregidos para que coincidan con los modelos Dart
 */
const { initializeApp } = require('firebase/app');
const { getFirestore, doc, setDoc, addDoc, collection, Timestamp, deleteDoc, getDocs, query } = require('firebase/firestore');
const fs = require('fs');

const opts = fs.readFileSync('./lib/firebase_options.dart', 'utf8');
const apiKey = opts.match(/apiKey:\s*'([^']+)'/)[1];
const app = initializeApp({ apiKey, projectId: 'vecindario-app-a746b' });
const db = getFirestore(app);

const UID = '95fxithk2pUIp4xOLqDVY10pAPp1';
const CID = 'torres_del_parque';
function ts(d) { return Timestamp.fromDate(d || new Date()); }
function ago(ms) { return Timestamp.fromDate(new Date(Date.now() - ms)); }

async function clearCollection(path) {
  try {
    const snap = await getDocs(query(collection(db, path)));
    for (const d of snap.docs) await deleteDoc(d.ref);
  } catch(e) {}
}

async function seed() {
  console.log('Limpiando y re-sembrando con campos correctos...\n');

  // Limpiar datos anteriores
  await clearCollection('services');
  await clearCollection('stores/tienda_julio/items');
  await clearCollection('stores');
  await clearCollection('external_services');
  await clearCollection(`communities/${CID}/posts`);
  await clearCollection(`communities/${CID}/circulars`);
  await clearCollection(`communities/${CID}/amenities`);
  await clearCollection(`communities/${CID}/pqrs`);
  await clearCollection(`communities/${CID}/fines`);
  await clearCollection(`communities/${CID}/finances`);
  console.log('Limpieza completada.\n');

  // 1. Comunidad
  console.log('1. Comunidad...');
  await setDoc(doc(db, 'communities', CID), {
    name: 'Torres del Parque', address: 'Cra 5 #26-60', city: 'Bogotá', estrato: 4,
    adminUid: UID, inviteCode: 'V3CIN0', memberCount: 127, createdAt: ts(),
  });

  // 2. Usuario admin
  console.log('2. Usuario admin...');
  await setDoc(doc(db, 'users', UID), {
    displayName: 'Julián Becerra', email: 'becerrarodriguezjulian@gmail.com',
    phone: '+573001234567', photoURL: '', communityId: CID,
    tower: '1', apartment: '501', role: 'admin', verified: true, createdAt: ts(),
  });

  // 3. Suscripción
  console.log('3. Suscripción Enterprise...');
  await setDoc(doc(db, 'subscriptions', CID), {
    communityId: CID, plan: 'enterprise', status: 'active',
    startDate: ts(), endDate: ts(new Date('2027-04-06')),
  });

  // 4. Posts — PostModel espera: text, likedBy (array), likes (int), imageURLs (array)
  console.log('4. Posts...');
  const postsCol = collection(db, `communities/${CID}/posts`);
  await addDoc(postsCol, {
    authorUid: UID, authorName: 'Julián Becerra', authorPhotoURL: '',
    text: 'Mañana fumigación en zonas comunes de 8am a 12pm. Mascotas adentro.',
    imageURLs: [], type: 'news', pinned: true,
    likes: 24, likedBy: [], commentCount: 8, createdAt: ago(2*3600000),
  });
  await addDoc(postsCol, {
    authorUid: 'u2', authorName: 'María López', authorPhotoURL: '',
    text: '¿Ya arreglaron el portón del parqueadero? Lleva 3 días dañado.',
    imageURLs: [], type: 'news', pinned: false,
    likes: 15, likedBy: ['u1','u3'], commentCount: 12, createdAt: ago(3*3600000),
  });
  await addDoc(postsCol, {
    authorUid: 'u3', authorName: 'Carlos Ruiz', authorPhotoURL: '',
    text: 'Se encontró gato gris en piso 4, torre 2. Si lo reconocen avísenme 🐱',
    imageURLs: [], type: 'news', pinned: false,
    likes: 31, likedBy: ['u1','u2',UID], commentCount: 5, createdAt: ago(5*3600000),
  });

  // 5. Servicios — ServiceModel espera: ownerUid, ownerName, priceDescription, ratingCount, imageURLs
  console.log('5. Servicios vecinales...');
  await addDoc(collection(db, 'services'), {
    communityId: CID, ownerUid: 'u4', ownerName: 'Ana Torres',
    title: 'Almuerzos caseros', description: 'Bandeja paisa, ajiaco, sancocho. Domicilio en el conjunto.',
    category: 'comida', price: 12000, priceDescription: '$12.000 - $18.000',
    imageURLs: [], rating: 4.8, ratingCount: 45, orderCount: 156,
    ownerPhotoURL: '', active: true, createdAt: ts(),
  });
  await addDoc(collection(db, 'services'), {
    communityId: CID, ownerUid: 'u5', ownerName: 'Camila Reyes',
    title: 'Manicure a domicilio', description: 'Semipermanente, acrílicas, decoración.',
    category: 'belleza', price: 15000, priceDescription: 'Desde $15.000',
    imageURLs: [], rating: 4.7, ratingCount: 38, orderCount: 203,
    ownerPhotoURL: '', active: true, createdAt: ts(),
  });
  await addDoc(collection(db, 'services'), {
    communityId: CID, ownerUid: 'u10', ownerName: 'Diego Ramírez',
    title: 'Clases de guitarra', description: 'Principiantes y avanzados. A domicilio.',
    category: 'hogar', price: 25000, priceDescription: '$25.000/hora',
    imageURLs: [], rating: 4.9, ratingCount: 12, orderCount: 67,
    ownerPhotoURL: '', active: true, createdAt: ts(),
  });

  // 6. Tiendas — StoreModel espera: deliveryTime (string), minOrder (int), imageURL, orderCount
  console.log('6. Tiendas...');
  await setDoc(doc(db, 'stores', 'tienda_julio'), {
    name: 'Tienda Don Julio', description: 'Abarrotes, frutas, verduras',
    ownerUid: 'u6', communityId: CID, imageURL: '',
    deliveryTime: '15-25 min', minOrder: 10000,
    active: true, rating: 4.6, orderCount: 234, createdAt: ts(),
  });
  // Items — StoreItemModel espera: storeId, name, price, available, category, sortOrder
  const items = [
    { storeId: 'tienda_julio', name: 'Leche entera 1L', price: 4200, description: '', imageURL: '', available: true, category: 'Lácteos', sortOrder: 1 },
    { storeId: 'tienda_julio', name: 'Pan tajado', price: 5800, description: '', imageURL: '', available: true, category: 'Panadería', sortOrder: 2 },
    { storeId: 'tienda_julio', name: 'Huevos x30', price: 18500, description: '', imageURL: '', available: true, category: 'Básicos', sortOrder: 3 },
    { storeId: 'tienda_julio', name: 'Arroz 1kg', price: 4500, description: '', imageURL: '', available: true, category: 'Granos', sortOrder: 4 },
    { storeId: 'tienda_julio', name: 'Aguacate', price: 3000, description: '', imageURL: '', available: true, category: 'Frutas', sortOrder: 5 },
    { storeId: 'tienda_julio', name: 'Plátano maduro x3', price: 2500, description: '', imageURL: '', available: true, category: 'Frutas', sortOrder: 6 },
  ];
  for (const item of items) {
    await addDoc(collection(db, 'stores/tienda_julio/items'), item);
  }

  await setDoc(doc(db, 'stores', 'panaderia'), {
    name: 'Panadería La Esquina', description: 'Pan artesanal, pasteles, café',
    ownerUid: 'u7', communityId: CID, imageURL: '',
    deliveryTime: '10-20 min', minOrder: 8000,
    active: true, rating: 4.8, orderCount: 189, createdAt: ts(),
  });

  await setDoc(doc(db, 'stores', 'drogueria'), {
    name: 'Droguería Salud+', description: 'Medicamentos, cuidado personal',
    ownerUid: 'u11', communityId: CID, imageURL: '',
    deliveryTime: '20-30 min', minOrder: 15000,
    active: true, rating: 4.5, orderCount: 98, createdAt: ts(),
  });

  // 7. Servicios externos — ExternalServiceModel espera: category en español, recommendedByName, recommendedByUid
  console.log('7. Servicios externos...');
  await addDoc(collection(db, 'external_services'), {
    name: 'ElectroFix', description: 'Instalaciones, reparaciones, cortos. Servicio 24h.',
    category: 'electricista', phone: '+573101234567', rating: 4.8, reviewCount: 45,
    sponsored: true, recommendedByName: 'Ana Torres', recommendedByUid: 'u4',
    active: true, createdAt: ts(),
  });
  await addDoc(collection(db, 'external_services'), {
    name: 'Plomería Rápida', description: 'Destape, grifos, tanques. Atención inmediata.',
    category: 'plomero', phone: '+573121234567', rating: 4.7, reviewCount: 28,
    sponsored: false, recommendedByName: 'Pedro M.', recommendedByUid: 'u8',
    active: true, createdAt: ts(),
  });
  await addDoc(collection(db, 'external_services'), {
    name: 'Cerrajería Express', description: 'Apertura, cambio de guardas, instalación cerraduras.',
    category: 'cerrajero', phone: '+573131234567', rating: 4.6, reviewCount: 19,
    sponsored: false, recommendedByName: 'María López', recommendedByUid: 'u2',
    active: true, createdAt: ts(),
  });

  // 8. Circulares
  console.log('8. Circulares...');
  const circs = collection(db, `communities/${CID}/circulars`);
  await addDoc(circs, {
    title: 'Corte de agua programado',
    body: 'Jueves 10 de abril: mantenimiento tanque principal. Corte de 8am a 2pm.',
    priority: 'urgent', authorUid: UID, authorName: 'Julián Becerra',
    attachments: [], readBy: [UID, 'u2'], totalResidents: 127,
    requiresSignature: false, createdAt: ago(2*3600000),
  });
  await addDoc(circs, {
    title: 'Horarios de Semana Santa',
    body: 'Administración: 8am-12pm. Portería: 24h sin cambios.',
    priority: 'info', authorUid: UID, authorName: 'Julián Becerra',
    attachments: [], readBy: [UID], totalResidents: 127,
    requiresSignature: false, createdAt: ago(86400000),
  });
  await addDoc(circs, {
    title: 'Nuevo reglamento de mascotas',
    body: 'Aprobada modificación capítulo VII del manual. Todos deben firmar acuse.',
    priority: 'signature', authorUid: UID, authorName: 'Julián Becerra',
    attachments: ['manual_v3.2.pdf'], readBy: [], signedBy: [], totalResidents: 127,
    requiresSignature: true, createdAt: ago(3*86400000),
  });

  // 9. Zonas sociales
  console.log('9. Zonas sociales...');
  const amen = collection(db, `communities/${CID}/amenities`);
  await addDoc(amen, {
    name: 'Salón Social', description: 'Salón para eventos y reuniones con cocina integrada',
    capacity: 40, hourlyRate: 80000, deposit: 50000, hours: '8:00 - 22:00',
    availableDays: ['lunes','martes','miercoles','jueves','viernes','sabado','domingo'],
    rules: 'No eventos después de 10pm. Máximo 40 personas.', maxBookingsPerMonth: 2, photoURLs: [],
  });
  await addDoc(amen, {
    name: 'BBQ / Asadero', description: 'Zona de BBQ con mesas y lavaplatos',
    capacity: 20, hourlyRate: 50000, deposit: 30000, hours: '10:00 - 21:00',
    availableDays: ['viernes','sabado','domingo'],
    rules: 'Traer carbón propio. Dejar limpio.', maxBookingsPerMonth: 2, photoURLs: [],
  });
  await addDoc(amen, {
    name: 'Cancha múltiple', description: 'Fútbol, basketball y volleyball',
    capacity: 30, hourlyRate: 0, deposit: null, hours: '6:00 - 21:00',
    availableDays: ['lunes','martes','miercoles','jueves','viernes','sabado','domingo'],
    rules: 'Solo calzado deportivo. Franjas de 2 horas.', maxBookingsPerMonth: 4, photoURLs: [],
  });

  // 10. PQRS
  console.log('10. PQRS...');
  const pqrs = collection(db, `communities/${CID}/pqrs`);
  await addDoc(pqrs, {
    authorUid: 'u8', authorName: 'Pedro Martínez', type: 'complaint', category: 'maintenance',
    title: 'Filtración en parqueadero', description: 'Gotera en P2 puesto 45, cae agua sobre los carros.',
    status: 'in_progress', adminResponse: '', imageUrls: [], createdAt: ago(3*3600000),
  });
  await addDoc(pqrs, {
    authorUid: 'u9', authorName: 'Laura Mendoza', type: 'request', category: 'security',
    title: 'Instalar cámaras en lobby', description: 'Solicitamos cámaras adicionales en lobby torre 3.',
    status: 'open', adminResponse: '', imageUrls: [], createdAt: ago(86400000),
  });
  await addDoc(pqrs, {
    authorUid: 'u4', authorName: 'Ana Torres', type: 'suggestion', category: 'common_areas',
    title: 'Horario extendido de gym', description: '¿Abrir gimnasio desde las 5am?',
    status: 'resolved', adminResponse: 'Aprobado a partir de mayo.', imageUrls: [], createdAt: ago(2*86400000),
  });

  // 11. Multa
  console.log('11. Multas...');
  await addDoc(collection(db, `communities/${CID}/fines`), {
    residentUid: 'u3', residentName: 'Carlos Ruiz', unitNumber: 'T2-801',
    amount: 200000, reason: 'Ruido excesivo en horario nocturno',
    manualArticle: 'Art. 23 — Horarios de silencio',
    description: 'Música a alto volumen después de las 10pm el sábado 28 de marzo.',
    status: 'appealing', imageUrls: [],
    descargoText: 'El evento terminó a las 10:30pm y bajamos el volumen al ser notificados.',
    descargoDeadline: ts(new Date(Date.now() + 2*86400000)),
    createdAt: ago(5*86400000), createdBy: UID,
  });

  // 12. Finanzas
  console.log('12. Finanzas...');
  const fin = collection(db, `communities/${CID}/finances`);
  await addDoc(fin, { type: 'income', category: 'Cuotas', amount: 15360000, month: '2026-03', description: 'Cuotas admin marzo' });
  await addDoc(fin, { type: 'income', category: 'Multas', amount: 800000, month: '2026-03', description: 'Recaudo multas' });
  await addDoc(fin, { type: 'income', category: 'Alquiler', amount: 2240000, month: '2026-03', description: 'Reservas zonas' });
  await addDoc(fin, { type: 'expense', category: 'Nómina', amount: 8500000, month: '2026-03', description: 'Vigilancia y aseo' });
  await addDoc(fin, { type: 'expense', category: 'Mantenimiento', amount: 3200000, month: '2026-03', description: 'Preventivo' });
  await addDoc(fin, { type: 'expense', category: 'Servicios', amount: 2100000, month: '2026-03', description: 'Agua, luz, gas' });
  await addDoc(fin, { type: 'expense', category: 'Seguros', amount: 800000, month: '2026-03', description: 'Póliza' });

  await setDoc(doc(db, `communities/${CID}/account_statements`, UID), {
    uid: UID, balance: 0, monthlyFee: 320000, status: 'current',
  });

  // 13. Residentes pendientes
  console.log('13. Residentes pendientes...');
  await setDoc(doc(db, 'users', 'pending_juan'), {
    displayName: 'Juan Pérez', email: 'juan@email.com', communityId: CID,
    tower: '3', apartment: '501', role: 'resident', verified: false, createdAt: ago(2*3600000),
  });
  await setDoc(doc(db, 'users', 'pending_laura'), {
    displayName: 'Laura Mendoza', email: 'laura@email.com', communityId: CID,
    tower: '1', apartment: '302', role: 'resident', verified: false, createdAt: ago(4*3600000),
  });
  await setDoc(doc(db, 'users', 'pending_andres'), {
    displayName: 'Andrés García', email: 'andres@email.com', communityId: CID,
    tower: '2', apartment: '704', role: 'resident', verified: false, createdAt: ago(6*3600000),
  });

  console.log('\n✅ Datos re-sembrados con campos corregidos!');
  console.log('\n   Cierra la app completamente y vuelve a abrirla.');
  process.exit(0);
}

seed().catch(e => { console.error('Error:', e.message || e); process.exit(1); });
