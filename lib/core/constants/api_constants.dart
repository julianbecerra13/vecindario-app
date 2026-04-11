class ApiConstants {
  ApiConstants._();

  // Base URL de Cloud Functions (configurar cuando se tenga proyecto Firebase)
  static const baseUrl = 'https://us-central1-YOUR_PROJECT.cloudfunctions.net';

  // Endpoints de Cloud Functions
  static const approveResident = '$baseUrl/ApproveResident';
  static const createOrder = '$baseUrl/CreateOrder';
  static const processPayment = '$baseUrl/ProcessPayment';
  static const exportUserData = '$baseUrl/ExportUserData';
  static const rotateInviteCode = '$baseUrl/RotateInviteCode';

  // Wompi (sandbox por defecto, cambiar a producción cuando aplique)
  static const wompiBaseUrl = 'https://sandbox.wompi.co/v1';
  static const wompiPublicKey = 'pub_test_XXXXXXXXXXXXXXXXX';

  // Timeouts
  static const connectionTimeout = Duration(seconds: 30);
  static const receiveTimeout = Duration(seconds: 30);

  // Paginación
  static const defaultPageSize = 20;
  static const maxPageSize = 50;

  // Límites de archivos
  static const maxImageSizeMB = 5;
  static const maxImagesPerPost = 4;
  static const maxImagesPerService = 5;
}
