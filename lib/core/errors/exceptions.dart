/// Base error for shared and feature-specific exception families.
///
/// This must remain extensible because booking, payment, and auth each define
/// their own domain-specific exception subtypes in separate libraries.
abstract class AppExceptions implements Exception {
  const AppExceptions({required this.message, this.code, this.cause});

  final String message;
  final String? code;
  final Object? cause;
}

class NetworkException extends AppExceptions {
  const NetworkException({
    super.message = 'Please check your internet connection and try again.',
    super.code,
    super.cause,
  });
}

class ValidationException extends AppExceptions {
  const ValidationException({required super.message, super.code, super.cause});
}

class PermissionException extends AppExceptions {
  const PermissionException({
    super.message = 'You do not have permission to perform this action.',
    super.code,
    super.cause,
  });
}

class ServerException extends AppExceptions {
  const ServerException({
    super.message = 'Our service is temporarily unavailable. Please try again.',
    super.code,
    super.cause,
  });
}

class UnknownException extends AppExceptions {
  const UnknownException({
    super.message = 'Something went wrong. Please try again.',
    super.code,
    super.cause,
  });
}

