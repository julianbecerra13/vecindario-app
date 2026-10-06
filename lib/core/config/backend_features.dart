/// Configuración pública de Cloudinary inyectada al compilar.
///
/// El upload preset debe ser `unsigned`, limitar formatos/tamaños desde
/// Cloudinary y no contiene secretos. Nunca se incluye el API secret en la app.
const String kCloudinaryCloudName = String.fromEnvironment(
  'CLOUDINARY_CLOUD_NAME',
);
const String kCloudinaryUploadPreset = String.fromEnvironment(
  'CLOUDINARY_UPLOAD_PRESET',
);
const bool kMediaUploadsEnabled = bool.fromEnvironment(
  'CLOUDINARY_UPLOADS_ENABLED',
);

const String kMediaUploadsUnavailableMessage =
    'Las cargas gratuitas necesitan configurar Cloudinary en esta versión.';
