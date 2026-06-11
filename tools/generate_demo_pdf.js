const PDFDocument = require('pdfkit');
const fs = require('fs');
const path = require('path');

const OUTPUT = 'C:\\Users\\becer\\OneDrive\\Escritorio\\Vecindario_Demo_Credenciales.pdf';

const COLORS = {
  primary: '#2563EB',
  dark: '#1E293B',
  text: '#334155',
  muted: '#64748B',
  border: '#E2E8F0',
  bg: '#F8FAFC',
  superAdmin: '#3B82F6',
  admin: '#10B981',
  resident: '#F59E0B',
  storeOwner: '#EF4444',
};

const PAGE_MARGIN = 50;

const doc = new PDFDocument({
  size: 'LETTER',
  margin: PAGE_MARGIN,
  info: {
    Title: 'Vecindario — Credenciales y Guía de Demo',
    Author: 'Vecindario',
    Subject: 'Demo Country Living',
  },
});

const writeStream = fs.createWriteStream(OUTPUT);
writeStream.on('finish', () => {
  console.log('✅ PDF generado:');
  console.log('   ' + OUTPUT);
  process.exit(0);
});
writeStream.on('error', (err) => {
  console.error('❌ Error escribiendo PDF:', err);
  process.exit(1);
});
doc.pipe(writeStream);

// ====== Helper helpers ======
function h1(text) {
  doc.moveDown(0.5);
  doc.fillColor(COLORS.dark).font('Helvetica-Bold').fontSize(22).text(text);
  doc.moveDown(0.3);
  const y = doc.y;
  doc.moveTo(PAGE_MARGIN, y).lineTo(612 - PAGE_MARGIN, y).strokeColor(COLORS.primary).lineWidth(2).stroke();
  doc.moveDown(0.5);
}

function h2(text, color = COLORS.dark) {
  doc.moveDown(0.6);
  doc.fillColor(color).font('Helvetica-Bold').fontSize(14).text(text);
  doc.moveDown(0.3);
}

function p(text, opts = {}) {
  doc.fillColor(opts.color || COLORS.text).font(opts.bold ? 'Helvetica-Bold' : 'Helvetica').fontSize(opts.size || 10).text(text, { paragraphGap: opts.gap || 3 });
}

function small(text) {
  doc.fillColor(COLORS.muted).font('Helvetica').fontSize(9).text(text);
}

function bullet(text, sub) {
  const x = doc.x;
  doc.fillColor(COLORS.primary).font('Helvetica-Bold').fontSize(11).text('•  ', { continued: true });
  doc.fillColor(COLORS.text).font('Helvetica').fontSize(10).text(text);
  if (sub) {
    doc.fillColor(COLORS.muted).font('Helvetica').fontSize(9).text('    ' + sub);
  }
  doc.x = x;
}

function ensureSpace(minY = 100) {
  if (doc.y > 792 - PAGE_MARGIN - minY) doc.addPage();
}

function credCard(role, email, color) {
  ensureSpace(60);
  const x = doc.x;
  const y = doc.y;
  const width = 612 - 2 * PAGE_MARGIN;
  const height = 50;

  doc.roundedRect(x, y, width, height, 6).fillColor(COLORS.bg).fill();
  doc.roundedRect(x, y, 6, height, 3).fillColor(color).fill();

  doc.fillColor(color).font('Helvetica-Bold').fontSize(11).text(role, x + 18, y + 8);
  doc.fillColor(COLORS.dark).font('Helvetica-Bold').fontSize(14).text(email, x + 18, y + 22);
  doc.fillColor(COLORS.muted).font('Helvetica').fontSize(10).text('Password: demo1234', x + 380, y + 22);

  doc.y = y + height + 10;
  doc.x = x;
}

// ====== COVER ======
doc.rect(0, 0, 612, 200).fillColor(COLORS.primary).fill();
doc.fillColor('white').font('Helvetica-Bold').fontSize(36).text('Vecindario', PAGE_MARGIN, 60);
doc.fillColor('white').font('Helvetica').fontSize(14).text('Credenciales y guía de demo', PAGE_MARGIN, 105);
doc.fillColor('white').font('Helvetica').fontSize(11).text('Conjunto Country Living  ·  432 unidades  ·  Plan Professional', PAGE_MARGIN, 130);
doc.fillColor('white').font('Helvetica-Oblique').fontSize(9).text('Código de invitación: COUNTRY', PAGE_MARGIN, 160);

doc.y = 220;
doc.x = PAGE_MARGIN;

// ====== SECCIÓN 1: Credenciales ======
h1('1. Cuentas de demo');
p('Todas las cuentas usan password ', { gap: 0 });
doc.fillColor(COLORS.primary).font('Helvetica-Bold').fontSize(10).text('demo1234', { continued: false });
doc.moveDown(0.3);

credCard('SUPER ADMIN', 'super@demo.com', COLORS.superAdmin);
credCard('ADMIN', 'admin@demo.com', COLORS.admin);
credCard('RESIDENTE', 'vecino@demo.com', COLORS.resident);
credCard('STORE OWNER', 'tienda@demo.com', COLORS.storeOwner);

// ====== SECCIÓN 2: Super Admin ======
h1('2. Super Admin');
h2('super@demo.com', COLORS.superAdmin);
bullet('Login cae directo al panel global');
bullet('Ver Country Living con badge del plan (Professional trial)');
bullet('Tap en la tarjeta', 'Cambiar plan, ver admin asignado');
bullet('Botón + arriba', 'Crear comunidad nueva');
bullet('Ícono logout arriba derecha', 'Cerrar sesión');

// ====== SECCIÓN 3: Admin ======
h1('3. Admin');
h2('admin@demo.com', COLORS.admin);
bullet('Login cae al feed con 6 posts', 'Incluye post fijado de bienvenida');
bullet('Avatar -> Perfil', 'Ver "Gestión del Conjunto" + sección "Mi conjunto"');
bullet('Ícono escudo arriba derecha del feed', 'Acceso directo al AdminShell con 5 tabs');

doc.moveDown(0.4);
p('AdminShell — 5 tabs:', { bold: true, size: 11 });
bullet('Inicio', 'Stats: residentes, PQRS abiertos, recaudo del mes');
bullet('Circulares', '3 circulares sembradas, botón + para crear, marcar leído/ack');
bullet('Finanzas', '10 movimientos ($18M abril + $18.2M mayo + egresos), FAB "Nuevo"');
bullet('Zonas', '4 amenidades (Salón Social, Gimnasio, Piscina, BBQ), FAB "Nueva"');
bullet('PQRS', '3 PQRS con stats (abiertos/en gestión/resueltos), botón responder');

doc.moveDown(0.4);
p('Desde perfil:', { bold: true, size: 11 });
bullet('Asambleas', 'FAB "+ Convocar" para crear asamblea con agenda y votaciones');

// ====== SECCIÓN 4: Residente ======
h1('4. Residente');
h2('vecino@demo.com', COLORS.resident);
bullet('Login cae al feed con 6 posts');

doc.moveDown(0.4);
p('4 tabs inferiores:', { bold: true, size: 11 });
bullet('Noticias', '6 posts del conjunto');
bullet('Vecinos', '8 servicios vecinales (clases de mat, arreglo PCs, peluquería, etc.)');
bullet('Tiendas', '3 tiendas (Dulcería Rosa, Mascotas, Mini Market) con items');
bullet('Servicios', '8 externos (electricista, plomero, cerrajero...)');

doc.moveDown(0.4);
p('Avatar -> "Mi conjunto" con 7 accesos:', { bold: true, size: 11 });
bullet('Circulares', '3 con marcar leído/ack');
bullet('Reservar zona', 'Selecciona Salón Social + fecha');
bullet('PQRS', 'Crear nueva (petición / queja / reclamo)');
bullet('Mis multas', 'Vacío por defecto');
bullet('Estado de cuenta');
bullet('Asambleas');
bullet('Manual de convivencia');

doc.moveDown(0.4);
p('Flujo compra: Tab Tiendas -> Dulcería Rosa -> agregar brownie al carrito -> ordenar', { bold: true, size: 10 });
small('Genera un pedido real que aparece en el panel del Store Owner');

// ====== SECCIÓN 5: Store Owner ======
h1('5. Store Owner');
h2('tienda@demo.com', COLORS.storeOwner);
bullet('Login cae al feed (también es vecino)');
bullet('Ícono tienda arriba derecha del feed', 'Panel de Dulcería Rosa con 3 tabs');

doc.moveDown(0.4);
p('Panel de tienda — 3 tabs:', { bold: true, size: 11 });

doc.moveDown(0.2);
p('Pedidos:', { bold: true, size: 10 });
bullet('2 pendientes', 'Carlos T2-1201 y María T1-401 -> Aceptar o Rechazar');
bullet('1 confirmado', 'Sofía T5-1203 -> "Marcar en camino" -> "Marcar entregado"');
bullet('1 entregado', 'Luis T2-802 (hace 2 días)');
bullet('Stats arriba', 'Pendientes / Activos / Hoy');

doc.moveDown(0.2);
p('Productos:', { bold: true, size: 10 });
bullet('4 items', 'Brownie, Cheesecake, Red Velvet, Galletas');
bullet('FAB +', 'Crear nuevo producto');
bullet('Menú de cada item', 'Editar / Ocultar / Eliminar');

doc.moveDown(0.2);
p('Información:', { bold: true, size: 10 });
bullet('Ver y editar', 'Nombre, descripción, tiempo entrega, pedido mínimo');
bullet('Pausar / reactivar tienda', 'Control manual de disponibilidad');

// ====== SECCIÓN 6: Flujo de presentación ======
h1('6. Flujo recomendado (15 min)');

bullet('1. Super Admin (2 min)', 'Mostrar que controlas qué comunidades existen y sus planes');
bullet('2. Admin (5 min)', 'Gestión real del conjunto: crear circular en vivo, responder PQRS, convocar asamblea');
bullet('3. Residente (5 min)', 'Experiencia del usuario final: feed, reservar salón, pedir en tienda');
bullet('4. Store Owner (3 min)', 'Negocios del conjunto: aceptar pedido en vivo, cambiar precio');

// ====== DATOS ÚTILES ======
doc.moveDown(0.8);
ensureSpace(80);
const y = doc.y;
doc.roundedRect(PAGE_MARGIN, y, 612 - 2 * PAGE_MARGIN, 70, 6).fillColor(COLORS.bg).fill();
doc.fillColor(COLORS.primary).font('Helvetica-Bold').fontSize(11).text('Datos útiles para la presentación', PAGE_MARGIN + 15, y + 10);
doc.fillColor(COLORS.text).font('Helvetica').fontSize(10);
doc.text('• La comunidad Country Living tiene 432 unidades (5 torres × 18 pisos, mix 4/6 aptos)', PAGE_MARGIN + 15, y + 28);
doc.text('• Plan Professional con trial de 30 días', PAGE_MARGIN + 15, y + 42);
doc.text('• Código de invitación: COUNTRY  ·  Backend Firebase + Cloud Functions Go', PAGE_MARGIN + 15, y + 56);

doc.y = y + 80;

// Footer
doc.moveDown(1);
doc.fillColor(COLORS.muted).font('Helvetica-Oblique').fontSize(8)
  .text('Generado para la demo de Vecindario. Stack: Flutter 3.32 / Dart 3.8 / Firebase / Cloud Functions Go.', { align: 'center' });

doc.end();
