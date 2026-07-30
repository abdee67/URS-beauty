import 'package:urs_beauty/core/errors/exceptions.dart';

class AuthExceptions extends AppExceptions {
  const AuthExceptions({required super.message, super.code, super.cause});
}

class InvalidCredentialsException extends AuthExceptions {
  const InvalidCredentialsException({
    super.message = 'Your email or password is incorrect.',
    super.code,
    super.cause,
  });
}

class InvalidOtpException extends AuthExceptions {
  const InvalidOtpException({
    super.message = 'That verification code is invalid or has expired.',
    super.code,
    super.cause,
  });
}

class SessionExpiredException extends AuthExceptions {
  const SessionExpiredException({
    super.message = 'Your session has expired. Please sign in again.',
    super.code,
    super.cause,
  });
}
