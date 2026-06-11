// Seed adicional: servicios vecinales (tab Vecinos) + externos (tab Servicios)
const admin = require('firebase-admin');
admin.initializeApp({ projectId: 'vecindario-app-a746b' });
const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;
const COMMUNITY_ID = 'country-living';

const services = [
  { ownerUid: 'seed-maria', ownerName: 'María González', title: 'Clases particulares de matemáticas', description: 'Primaria y bachillerato. Pedagoga con 10 años de experiencia. Clases presenciales o virtuales.', category: 'hogar', price: 40000, priceDescription: '\$40.000/hora' },
  { ownerUid: 'seed-luis', ownerName: 'Luis Martínez', title: 'Arreglo de computadores', description: 'Formateo, limpieza, instalación de software. 20 años reparando PCs.', category: 'tecnologia', price: 60000 },
  { ownerUid: 'seed-sofia', ownerName: 'Sofía Ramírez', title: 'Peluquería a domicilio', description: 'Corte, tinte, cepillado. Llevo mis propios implementos. Cita previa.', category: 'belleza', priceDescription: 'Desde \$25.000' },
  { ownerUid: 'seed-ana', ownerName: 'Ana Rodríguez', title: 'Postres por encargo', description: 'Tortas, cupcakes, postres fríos. Eventos y cumpleaños.', category: 'comida', priceDescription: 'Cotización según pedido' },
  { ownerUid: 'seed-pedro', ownerName: 'Pedro Castro', title: 'Paseador de perros', description: 'Paseos de 30 min o 1 hora. Zonas verdes cercanas. Recoge y entrega en tu apto.', category: 'mascotas', price: 15000, priceDescription: '\$15.000/paseo' },
  { ownerUid: 'seed-diego', ownerName: 'Diego Ortiz', title: 'Reparaciones eléctricas menores', description: 'Tomas, bombillos, duchas eléctricas. Vivo en el conjunto, respuesta rápida.', category: 'hogar', price: 30000, priceDescription: 'Desde \$30.000' },
  { ownerUid: 'seed-maria', ownerName: 'María González', title: 'Ropa tejida a mano', description: 'Suéteres, bufandas, gorros. Diseños únicos para adultos y niños.', category: 'ropa', priceDescription: 'Desde \$60.000' },
  { ownerUid: 'seed-sofia', ownerName: 'Sofía Ramírez', title: 'Entrenadora personal', description: 'Rutinas en casa o gimnasio del conjunto. Pérdida de peso, tonificación.', category: 'salud', price: 45000, priceDescription: '\$45.000/sesión' },
];

const externalServices = [
  { name: 'Electro-Fix', category: 'electricista', phone: '+57 300 111 2233', description: 'Electricista certificado. Atención 24/7 para emergencias. Instalaciones residenciales e industriales.', rating: 4.8, reviewCount: 47, sponsored: true, recommendedByName: 'Administración' },
  { name: 'Plomería Rápida Bogotá', category: 'plomero', phone: '+57 301 222 3344', description: 'Destape de tuberías, reparación de fugas, instalación de sanitarios. Presupuesto gratis.', rating: 4.6, reviewCount: 89, sponsored: false, recommendedByName: 'Administración' },
  { name: 'Cerrajería Express 24h', category: 'cerrajero', phone: '+57 302 333 4455', description: 'Apertura de puertas, cambio de guardas, duplicado de llaves. Disponible de madrugada.', rating: 4.9, reviewCount: 156, sponsored: true },
  { name: 'Aseo Total', category: 'aseo', phone: '+57 303 444 5566', description: 'Servicio de aseo profundo, lavado de muebles y alfombras. Productos biodegradables.', rating: 4.7, reviewCount: 34, sponsored: false, recommendedByName: 'María González' },
  { name: 'Mudanzas Seguras', category: 'mudanzas', phone: '+57 304 555 6677', description: 'Camiones de 2 a 8 toneladas. Embalaje, transporte, armado de muebles. Cobertura nacional.', rating: 4.5, reviewCount: 62, sponsored: false },
  { name: 'Pintura y Decoración HR', category: 'pintura', phone: '+57 305 666 7788', description: 'Pintura interior y exterior, texturizados, papel de colgadura. 15 años de experiencia.', rating: 4.8, reviewCount: 28, sponsored: false, recommendedByName: 'Luis Martínez' },
  { name: 'Jardines Verdes', category: 'jardineria', phone: '+57 306 777 8899', description: 'Poda, siembra, mantenimiento de jardines y plantas interiores. Asesoría en paisajismo.', rating: 4.6, reviewCount: 19, sponsored: false },
  { name: 'Carpintería Don Julio', category: 'carpinteria', phone: '+57 307 888 9900', description: 'Muebles a medida, clósets, cocinas integrales, reparaciones. Trabajos en madera fina.', rating: 4.9, reviewCount: 73, sponsored: true, recommendedByName: 'Administración' },
];

async function main() {
  console.log('🌱 Seed de services y external_services...');

  for (const s of services) {
    await db.collection('services').add({
      ...s,
      communityId: COMMUNITY_ID,
      rating: 4.3 + Math.random() * 0.7,
      ratingCount: Math.floor(Math.random() * 30) + 5,
      orderCount: Math.floor(Math.random() * 20),
      active: true,
      imageURLs: [],
      createdAt: FieldValue.serverTimestamp(),
    });
  }
  console.log(`  ✓ ${services.length} servicios vecinales creados`);

  for (const e of externalServices) {
    await db.collection('external_services').add({
      ...e,
      active: true,
      createdAt: FieldValue.serverTimestamp(),
    });
  }
  console.log(`  ✓ ${externalServices.length} servicios externos creados`);

  console.log('\n✅ Listo. Haz refresh en la app (pull down) o navega entre tabs.');
  process.exit(0);
}

main().catch(err => { console.error('❌', err); process.exit(1); });
