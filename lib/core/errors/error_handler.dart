import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/core/errors/exceptions.dart';
import 'package:urs_beauty/core/errors/failures.dart';

class ErrorMapper {
  ErrorMapper._();

  static AppExceptions toException(Object error, [StackTrace? stackTrace]) {
    if (error is AppExceptions) return error;
    if (error is SocketException || error is TimeoutException) {
      return NetworkException(cause: error);
    }
    if (error is AuthApiException) return _fromAuth(error);
    if (error is PostgrestException) return _fromPostgrest(error);
    if (error is FunctionException) {
      return ServerException(
        message:
            _functionMessage(error) ?? 'The request could not be completed.',
        cause: error,
      );
    }
    return _fromText(error.toString(), error);
  }

  static AppExceptions _fromAuth(AuthApiException error) {
    final code = error.code;
    final text = '${error.message} $code'.toLowerCase();
    if (text.contains('invalid login') || text.contains('invalid credentials')) {
      return InvalidCredentialsException(code: code, cause: error);
    }
    if (text.contains('otp') ||
        text.contains('token') ||
        text.contains('expired')) {
      return InvalidOtpException(code: code, cause: error);
    }
    if (text.contains('already registered') ||
        text.contains('already been registered')) {
      return AuthExceptions(
        message:
            'An account already exists for this email. Please sign in instead.',
        code: code,
        cause: error,
      );
    }
    if (text.contains('weak password')) {
      return AuthExceptions(
        message: 'Use a stronger password and try again.',
        code: code,
        cause: error,
      );
    }
    return AuthExceptions(
      message: 'We could not complete that account request. Please try again.',
      code: code,
      cause: error,
    );
  }

  static AppExceptions _fromPostgrest(PostgrestException error) {
    if (error.code == '42501') {
      return PermissionException(cause: error, code: error.code);
    }
    if (error.code == '23505') {
      return ValidationException(
        message: 'This information already exists.',
        cause: error,
        code: error.code,
      );
    }
    return ServerException(cause: error, code: error.code);
  }

  static AppExceptions _fromText(String value, Object cause) {
    final text = value.replaceFirst('Exception: ', '').toLowerCase();
    if (text.contains('network') ||
        text.contains('socket') ||
        text.contains('timed out')) {
      return NetworkException(cause: cause);
    }
    if (text.contains('invalid login') || text.contains('invalid credentials')) {
      return InvalidCredentialsException(cause: cause);
    }
    if (text.contains('otp') ||
        text.contains('token') ||
        text.contains('verification code')) {
      return InvalidOtpException(cause: cause);
    }
    if (text.contains('session') || text.contains('authenticated user')) {
      return SessionExpiredException(cause: cause);
    }
    return UnknownException(cause: cause);
  }

  static String? _functionMessage(FunctionException error) {
    final details = error.details;
    return details is Map && details['message'] != null
        ? details['message'].toString()
        : null;
  }

  static Failures toFailure(AppExceptions exception) {
    if (exception is NetworkException) {
      return NetworkFailure(message: exception.message, code: exception.code);
    }
    if (exception is ValidationException) {
      return ValidationFailure(
        message: exception.message,
        code: exception.code,
      );
    }
    if (exception is PermissionException ||
        exception is SessionExpiredException){
      return PermissionFailure(
        message: exception.message,
        code: exception.code,
      );
        }
    if (exception is AuthException){
      return AuthFailure(message: exception.message, code: exception.code);
    }

    if (exception is ServerException){
      return ServerFailure(message: exception.message, code: exception.code);
    }
    return Failures(message: exception.message, code: exception.code);
  }
}

Future<Either<Failures, T>> repositoryGuard<T>(
  Future<T> Function() operation,
) async {
  try {
    return Right(await operation());
  } catch (error, stackTrace) {
    final exception = ErrorMapper.toException(error, stackTrace);
    if (kDebugMode){
      developer.log(
        exception.message,
        name: 'repositoryGuard',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return Left(ErrorMapper.toFailure(exception));
  }
}

extension LegacyErrorHandler on Object {
  Future<Either<Failures, T>> repoErrorHnadler<T>(
    Future<T> Function() operation,
  ) => repositoryGuard(operation);

  Future<T> serviceError<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      final exception = ErrorMapper.toException(error, stackTrace);
      throw ErrorMapper.toFailure(exception);
    }
  }

  void requireValue(String value, String message) {
    if (value.trim().isEmpty) throw ValidationException(message: message);
  }

  String friendlyMessage(Object error) =>
      ErrorMapper.toException(error).message;
}
