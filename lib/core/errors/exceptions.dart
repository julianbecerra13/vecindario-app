class ServerException implements Exception {
  final String message;
  final String? code;
  const ServerException(this.message, {this.code});

  @override
  String toString() => 'ServerException($message)';
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);

  @override
  String toString() => 'CacheException($message)';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Sin conexión a internet']);

  @override
  String toString() => 'NetworkException($message)';
}
