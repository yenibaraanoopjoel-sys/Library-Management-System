/// Base exception class for all domain-specific errors
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Specific exception subclasses
class AuthException extends AppException {
  const AuthException({required super.message, super.code, super.details});
}

class DatabaseException extends AppException {
  const DatabaseException({required super.message, super.code, super.details});
}

class ValidationException extends AppException {
  const ValidationException({required super.message, super.code, super.details});
}

class NotFoundException extends AppException {
  const NotFoundException({required super.message, super.code, super.details});
}

class NetworkException extends AppException {
  const NetworkException({required super.message, super.code, super.details});
}
