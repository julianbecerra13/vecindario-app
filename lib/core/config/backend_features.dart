/// Capacidades dependientes de servicios externos.
///
/// Firebase Storage requiere facturación en el proyecto actual. Mientras se
/// activa, las funciones de datos continúan usando Auth y Firestore reales,
/// pero la interfaz no ofrece cargas que inevitablemente fallarían.
const bool kMediaUploadsEnabled = false;

const String kMediaUploadsUnavailableMessage =
    'Las cargas de archivos estarán disponibles cuando se active el almacenamiento del servidor.';
