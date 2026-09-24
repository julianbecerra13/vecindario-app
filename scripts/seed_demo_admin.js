/** Idempotent production demo seed. Never deletes data outside DEMO_CID. */
const admin = require('firebase-admin');

const PROJECT_ID = 'vecindario-app-a746b';
const DEMO_CID = 'demo-mirador-cedros';
const PASSWORD = process.env.DEMO_PASSWORD || 'VecindarioDemo2026!';
admin.initializeApp({
  projectId: PROJECT_ID,
  credential: admin.credential.applicationDefault(),
});
const db = admin.firestore();
const auth = admin.auth();
const T = admin.firestore.Timestamp;
const now = new Date();
const daysAgo = (days, hours = 0) => T.fromDate(new Date(now.getTime() - (days * 24 + hours) * 3600000));
const daysFromNow = days => T.fromDate(new Date(now.getTime() + days * 86400000));

const profiles = [
  ['resident.demo@vecindario.test', 'Sofía Martínez', 'resident', '', '1', '402', true],
  ['admin.demo@vecindario.test', 'Laura Gómez · Administradora', 'admin', '', '1', '101', true],
  ['superadmin.demo@vecindario.test', 'Dirección Vecindario', 'resident', 'super_admin', '', '', true],
  ['tienda.demo@vecindario.test', 'Carlos Ramírez · Mercado Cedros', 'resident', '', '2', '205', true],
  ['servicio.demo@vecindario.test', 'Andrés Torres · Técnico', 'resident', '', '3', '704', true],
  ['pendiente.demo@vecindario.test', 'Valentina Rojas', 'resident', '', '2', '301', false],
];

async function ensureUser([email, displayName]) {
  try {
    const user = await auth.getUserByEmail(email);
    return (await auth.updateUser(user.uid, {password: PASSWORD, displayName, emailVerified: true})).uid;
  } catch (e) {
    if (e.code !== 'auth/user-not-found') throw e;
    return (await auth.createUser({email, password: PASSWORD, displayName, emailVerified: true})).uid;
  }
}

async function seed() {
  const uid = {};
  for (const profile of profiles) uid[profile[0]] = await ensureUser(profile);
  const resident = uid[profiles[0][0]], manager = uid[profiles[1][0]], superadmin = uid[profiles[2][0]];
  const merchant = uid[profiles[3][0]], provider = uid[profiles[4][0]], pending = uid[profiles[5][0]];
  const batch = db.batch();
  const put = (documentPath, data) => batch.set(db.doc(documentPath), data, {merge: true});

  put(`communities/${DEMO_CID}`, {
    name: 'Conjunto Mirador de los Cedros (Demo)', address: 'Carrera 17 # 134-26', city: 'Bogotá',
    estrato: 4, adminUid: manager, inviteCode: 'CEDR26', memberCount: 148,
    unitType: 'apartment', createdAt: daysAgo(760), demo: true,
  });
  put('invite_codes/CEDR26', {
    communityId: DEMO_CID,
    unitType: 'apartment',
    updatedAt: now,
    demo: true,
  });
  profiles.forEach((p, i) => put(`users/${uid[p[0]]}`, {
    displayName: p[1], email: p[0], phone: `+573105550${String(i + 1).padStart(3, '0')}`,
    photoURL: null, communityId: p[3] ? null : DEMO_CID, communityRole: p[2],
    ...(p[3] ? {platformRole: p[3]} : {}), tower: p[4], apartment: p[5],
    estrato: 4, verified: p[6], createdAt: daysAgo(700 - i * 37), demo: true,
  }));
  put(`subscriptions/${DEMO_CID}`, {
    plan: 'enterprise', status: 'active', createdBy: superadmin, createdAt: daysAgo(730),
    trialStartedAt: daysAgo(760), trialEndsAt: daysAgo(730), demo: true,
  });

  const posts = [
    ['bienvenida-2024', manager, 'Laura Gómez · Administradora', '¡Bienvenidos al nuevo canal digital del conjunto! Aquí centralizaremos avisos, solicitudes y actividades.', 728, true, 83],
    ['aniversario', resident, 'Sofía Martínez', 'Dos años usando Vecindario 🎉 Qué diferencia tener toda la información y los servicios en un solo lugar.', 8, false, 46],
    ['mercado-campesino', merchant, 'Carlos Ramírez', 'Este sábado tendremos mercado campesino en la plazoleta de 8:00 a. m. a 1:00 p. m. Hay frutas, pan y café local.', 3, false, 31],
    ['mascota-encontrada', resident, 'Sofía Martínez', 'Encontramos un perrito con collar azul cerca de la torre 3. Está en portería mientras aparece su familia 🐶', 1, false, 25],
    ['mantenimiento-ascensor', manager, 'Laura Gómez · Administradora', 'Mañana se realizará mantenimiento preventivo del ascensor de la torre 2 entre 9:00 a. m. y 12:00 m.', 0, true, 18],
    ['clase-yoga', provider, 'Andrés Torres', 'Los miércoles seguimos con yoga en el salón comunal. Quedan cuatro cupos para el grupo de las 7:00 p. m.', 12, false, 21],
  ];
  for (const [id, authorUid, authorName, text, age, pinned, likes] of posts) {
    put(`communities/${DEMO_CID}/posts/${id}`, {authorUid, authorName, authorPhotoURL: null, text, imageURLs: [], type: 'news', pinned, likes, likedBy: [resident, merchant, provider].slice(0, Math.min(3, likes)), commentCount: 3, createdAt: daysAgo(age), demo: true});
    const replies = [
      [resident, 'Sofía Martínez', '¡Gracias por avisar!'],
      [merchant, 'Carlos Ramírez', 'Excelente, lo tendremos presente.'],
      [provider, 'Andrés Torres', 'Compartido con los vecinos de mi torre 👍'],
    ];
    replies.forEach((c, n) => put(`communities/${DEMO_CID}/posts/${id}/comments/comentario-${n + 1}`, {authorUid: c[0], authorName: c[1], authorPhotoURL: null, text: c[2], createdAt: daysAgo(Math.max(0, age - 1), n), demo: true}));
  }

  const circulars = [
    ['asamblea-2026', 'Convocatoria Asamblea General 2026', 'La asamblea ordinaria será el 26 de septiembre a las 6:30 p. m. en el salón social.', 'urgent', 5, true],
    ['lavado-tanques', 'Lavado semestral de tanques', 'El martes habrá suspensión de agua de 8:00 a. m. a 3:00 p. m.', 'important', 18, false],
    ['balance-agosto', 'Informe financiero de agosto', 'Ya está disponible el resumen de ingresos, gastos y cartera del conjunto.', 'info', 28, false],
    ['seguridad-vacaciones', 'Recomendaciones de seguridad', 'Registre visitantes y viajes en portería y no deje llaves con personas no autorizadas.', 'info', 61, false],
  ];
  circulars.forEach(c => put(`communities/${DEMO_CID}/circulars/${c[0]}`, {title: c[1], body: c[2], priority: c[3], authorUid: manager, authorName: 'Laura Gómez', attachmentURLs: [], readBy: [resident, merchant, provider], ackBy: c[5] ? [resident] : [], requiresAcknowledgment: c[5], createdAt: daysAgo(c[4]), demo: true}));

  const amenities = [
    ['salon-social', 'Salón social', 'Espacio para reuniones y celebraciones con cocina y terraza.', 60, 90000, 150000],
    ['zona-bbq', 'Zona BBQ', 'Dos asadores, mesones y mobiliario exterior.', 24, 45000, 80000],
    ['cancha-multiple', 'Cancha múltiple', 'Fútbol, baloncesto y voleibol.', 30, 0, null],
  ];
  amenities.forEach(a => put(`communities/${DEMO_CID}/amenities/${a[0]}`, {name: a[1], description: a[2], photoURLs: [], capacity: a[3], hourlyRate: a[4], deposit: a[5], rules: 'Reservar con anticipación y entregar el espacio limpio.', availableDays: ['lunes','martes','miercoles','jueves','viernes','sabado','domingo'], hours: '08:00 - 22:00', maxBookingsPerMonth: 3, demo: true}));
  put('bookings/demo-reserva-proxima', {communityId: DEMO_CID, amenityId: 'salon-social', amenityName: 'Salón social', residentUid: resident, residentName: 'Sofía Martínez', date: daysFromNow(9), startTime: '16:00', endTime: '21:00', totalPaid: 240000, depositPaid: 150000, depositRefunded: false, status: 'confirmed', createdAt: daysAgo(4), demo: true});
  put('bookings/demo-reserva-pasada', {communityId: DEMO_CID, amenityId: 'zona-bbq', amenityName: 'Zona BBQ', residentUid: resident, residentName: 'Sofía Martínez', date: daysAgo(42), startTime: '12:00', endTime: '16:00', totalPaid: 125000, depositPaid: 80000, depositRefunded: true, status: 'completed', createdAt: daysAgo(55), demo: true});

  put('stores/demo-mercado-cedros', {name: 'Mercado Cedros', description: 'Abarrotes, frutas, pan y productos esenciales con entrega dentro del conjunto.', ownerUid: merchant, communityId: DEMO_CID, imageURL: null, deliveryTime: '15-25 min', minOrder: 10000, active: true, rating: 4.8, orderCount: 386, createdAt: daysAgo(620), demo: true});
  const items = [['leche','Leche entera 1 L',4800,'Lácteos'],['pan','Pan artesanal',7500,'Panadería'],['huevos','Huevos AA x30',19800,'Despensa'],['frutas','Canasta de frutas',24000,'Frutas'],['cafe','Café colombiano 500 g',28500,'Bebidas']];
  items.forEach((x, n) => put(`stores/demo-mercado-cedros/items/${x[0]}`, {storeId: 'demo-mercado-cedros', name: x[1], description: '', price: x[2], imageURL: null, available: true, category: x[3], sortOrder: n + 1, demo: true}));
  put('orders/demo-pedido-entregado', {storeId: 'demo-mercado-cedros', storeName: 'Mercado Cedros', buyerUid: resident, buyerName: 'Sofía Martínez', buyerApartment: 'T1-402', items: [{name:'Pan artesanal',price:7500,quantity:2},{name:'Leche entera 1 L',price:4800,quantity:2}], subtotal:24600, serviceFee:350, total:24950, status:'delivered', paymentMethod:'cash', createdAt:daysAgo(6), confirmedAt:daysAgo(6), deliveredAt:daysAgo(6), demo:true});
  put('orders/demo-pedido-pendiente', {storeId: 'demo-mercado-cedros', storeName: 'Mercado Cedros', buyerUid: resident, buyerName: 'Sofía Martínez', buyerApartment: 'T1-402', items: [{name:'Canasta de frutas',price:24000,quantity:1}], subtotal:24000, serviceFee:350, total:24350, status:'pending', paymentMethod:'cash', createdAt:daysAgo(0,1), demo:true});

  const services = [
    ['demo-servicio-tecnico', provider, 'Andrés Torres', 'Reparaciones y mantenimiento', 'Electricidad, plomería menor e instalación de accesorios.', 'hogar', 4.9, 74],
    ['demo-clases-ingles', resident, 'Sofía Martínez', 'Clases de inglés', 'Clases personalizadas para niños y adultos.', 'educacion', 4.8, 39],
    ['demo-comida-casera', merchant, 'Carlos Ramírez', 'Almuerzos caseros', 'Menú diario con opción vegetariana y entrega en portería.', 'comida', 4.7, 112],
  ];
  services.forEach(s => put(`services/${s[0]}`, {ownerUid:s[1], ownerName:s[2], ownerPhotoURL:null, communityId:DEMO_CID, title:s[3], description:s[4], category:s[5], price:25000, priceDescription:'Desde $25.000', imageURLs:[], active:true, rating:s[6], ratingCount:s[7], orderCount:s[7]*2, createdAt:daysAgo(590), demo:true}));

  const pqrs = [
    ['iluminacion', resident, 'Sofía Martínez', 'request', 'maintenance', 'Dos luminarias del sendero entre las torres 1 y 2 están apagadas.', 'inProgress', 2, null],
    ['bicicleteros', merchant, 'Carlos Ramírez', 'suggestion', 'commonAreas', 'Sería útil ampliar el bicicletero del sótano 1.', 'received', 7, null],
    ['filtracion', provider, 'Andrés Torres', 'complaint', 'maintenance', 'Hay una filtración pequeña sobre el parqueadero 67.', 'resolved', 34, 'Impermeabilización realizada y verificada.'],
    ['ruido-porteria', resident, 'Sofía Martínez', 'petition', 'security', 'Solicito revisar el protocolo de ingreso de domicilios en la noche.', 'closed', 96, 'El protocolo fue actualizado y comunicado a vigilancia.'],
  ];
  pqrs.forEach(p => put(`communities/${DEMO_CID}/pqrs/${p[0]}`, {residentUid:p[1], residentName:p[2], residentUnit:'T1-402', type:p[3], category:p[4], description:p[5], photoURLs:[], assignedTo:manager, status:p[6], response:p[8], slaDeadline:daysAgo(Math.max(0,p[7]-5)), ...(p[8]?{resolvedAt:daysAgo(p[7]-1)}:{}), createdAt:daysAgo(p[7]), demo:true}));
  put(`communities/${DEMO_CID}/fines/ruido-2026`, {unitNumber:'T1-402', residentUid:resident, amount:180000, reason:'Ruido fuera del horario permitido', manualArticle:'Artículo 34', evidenceURLs:[], status:'defense', defenseText:'Solicito revisar el registro de portería; el ruido provenía del apartamento contiguo.', defenseDeadline:daysFromNow(3), createdAt:daysAgo(2), demo:true});
  put(`communities/${DEMO_CID}/fines/parqueo-2025`, {unitNumber:'T1-402', residentUid:resident, amount:95000, reason:'Estacionamiento en zona de visitantes', manualArticle:'Artículo 18', evidenceURLs:[], status:'paid', defenseText:null, createdAt:daysAgo(210), demo:true});

  for (let m = 0; m < 18; m++) {
    const d = new Date(now.getFullYear(), now.getMonth() - m, 1);
    const month = `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}`;
    put(`communities/${DEMO_CID}/finances/${month}-ingresos`, {type:'income', category:'Cuotas de administración', amount:38200000 + (m%4)*420000, description:`Recaudo mensual ${month}`, date:T.fromDate(d), month, createdBy:manager, createdAt:T.fromDate(d), demo:true});
    put(`communities/${DEMO_CID}/finances/${month}-gastos`, {type:'expense', category:'Operación y mantenimiento', amount:29100000 + (m%3)*610000, description:`Nómina, vigilancia, aseo y mantenimiento ${month}`, date:T.fromDate(d), month, createdBy:manager, createdAt:T.fromDate(d), demo:true});
  }
  put(`communities/${DEMO_CID}/account_statements/${resident}`, {uid:resident, residentName:'Sofía Martínez', unitNumber:'T1-402', balance:0, monthlyFee:365000, status:'current', updatedAt:daysAgo(1), demo:true});
  put('reviews/demo-resena-servicio', {authorUid:resident, authorName:'Sofía Martínez', targetId:'demo-servicio-tecnico', targetType:'service', rating:5, comment:'Puntual, cuidadoso y solucionó el problema el mismo día.', createdAt:daysAgo(23), demo:true});

  await batch.commit();
  console.log(JSON.stringify({projectId:PROJECT_ID, communityId:DEMO_CID, inviteCode:'CEDR26', users:profiles.map(p=>({role:p[3]||p[2],email:p[0],verified:p[6]})), password:PASSWORD}, null, 2));
}

seed().catch(e => {console.error(e.stack || e); process.exit(1);});
