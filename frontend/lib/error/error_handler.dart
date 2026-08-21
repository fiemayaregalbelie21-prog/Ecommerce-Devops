class AppException implements Exception {
  AppException(this.message, [this.code]);

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message, 'NETWORK_ERROR');
}

class AuthException extends AppException {
  AuthException(String message) : super(message, 'AUTH_ERROR');
}

class CacheException extends AppException {
  CacheException(String message) : super(message, 'CACHE_ERROR');
}

class ServerException extends AppException {
  ServerException(String message) : super(message, 'SERVER_ERROR');
}
