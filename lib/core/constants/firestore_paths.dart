class FirestorePaths {
  FirestorePaths._();

  // Colecciones principales
  static const users = 'users';
  static const communities = 'communities';
  static const services = 'services';
  static const stores = 'stores';
  static const orders = 'orders';
  static const externalServices = 'external_services';
  static const reviews = 'reviews';
  static const deletionRequests = 'deletion_requests';
  static const consents = 'consents';
  static const subscriptions = 'subscriptions';
  static const auditLogs = 'audit_logs';

  // Sub-colecciones de communities
  static String posts(String communityId) =>
      '$communities/$communityId/posts';

  static String comments(String communityId, String postId) =>
      '$communities/$communityId/posts/$postId/comments';

  // Sub-colecciones premium
  static String circulars(String communityId) =>
      '$communities/$communityId/circulars';

  static String fines(String communityId) =>
      '$communities/$communityId/fines';

  static String amenities(String communityId) =>
      '$communities/$communityId/amenities';

  static String bookings(String communityId) =>
      '$communities/$communityId/bookings';

  static String finances(String communityId) =>
      '$communities/$communityId/finances';

  static String budgets(String communityId) =>
      '$communities/$communityId/budgets';

  static String accountStatements(String communityId) =>
      '$communities/$communityId/account_statements';

  static String manualVersions(String communityId) =>
      '$communities/$communityId/manual_versions';

  static String assemblies(String communityId) =>
      '$communities/$communityId/assemblies';

  static String pqrs(String communityId) =>
      '$communities/$communityId/pqrs';

  // Documentos específicos
  static String user(String uid) => '$users/$uid';
  static String community(String id) => '$communities/$id';
  static String service(String id) => '$services/$id';
  static String store(String id) => '$stores/$id';
  static String order(String id) => '$orders/$id';
  static String externalService(String id) => '$externalServices/$id';
  static String review(String id) => '$reviews/$id';
  static String subscription(String communityId) =>
      '$subscriptions/$communityId';
}
