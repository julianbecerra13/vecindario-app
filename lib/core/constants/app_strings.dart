class AppStrings {
  AppStrings._();

  static const appName = 'Vecindario';
  static const appSlogan = 'Tu comunidad, conectada';

  // Categorías de servicios de vecinos
  static const serviceCategories = [
    'Comida',
    'Belleza',
    'Tecnología',
    'Mascotas',
    'Hogar',
    'Manualidades',
    'Salud',
    'Ropa',
  ];

  // Categorías de servicios externos
  static const externalCategories = [
    'Electricista',
    'Plomero',
    'Cerrajero',
    'Aseo',
    'Mudanzas',
    'Pintura',
    'Jardinería',
    'Carpintería',
  ];

  // Tipos de post
  static const postTypeNews = 'Noticia';
  static const postTypeAlert = 'Alerta';
  static const postTypePoll = 'Encuesta';

  // Estados de pedido
  static const orderStatusPending = 'Pendiente';
  static const orderStatusConfirmed = 'Confirmado';
  static const orderStatusDelivered = 'Entregado';
  static const orderStatusCancelled = 'Cancelado';

  // Roles
  static const roleResident = 'Residente';
  static const roleAdmin = 'Administrador';
  static const roleStoreOwner = 'Tienda';
  static const roleExternal = 'Servicio externo';

  // Estratos
  static const estratoLabels = [
    'Estrato 1 - Bajo-bajo',
    'Estrato 2 - Bajo',
    'Estrato 3 - Medio-bajo',
    'Estrato 4 - Medio',
    'Estrato 5 - Medio-alto',
    'Estrato 6 - Alto',
  ];

  // Comisiones por estrato (COP)
  static const estratoFees = [200, 200, 300, 350, 450, 500];

  // WhatsApp message template
  static String whatsappServiceMessage(String title) =>
      'Hola, vi tu servicio "$title" en Vecindario y me interesa. ¿Podrías darme más información?';

  static String whatsappExternalMessage(String name) =>
      'Hola $name, te contacto a través de Vecindario. Me gustaría consultar sobre tus servicios.';
}
