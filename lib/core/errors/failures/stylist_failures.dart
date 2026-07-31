import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/core/errors/exceptions/stylist_exceptions.dart';
import 'package:urs_beauty/core/errors/failures.dart';

abstract class StylistFailure extends Failures {
  const StylistFailure({required super.message, super.code});
}

class StylistValidationFailure extends StylistFailure {
  const StylistValidationFailure({required super.message, super.code});
}

class StylistNetworkFailure extends StylistFailure {
  const StylistNetworkFailure({required super.message, super.code});
}

class StylistNotFoundFailure extends StylistFailure {
  const StylistNotFoundFailure({required super.message, super.code});
}

class StylistPermissionFailure extends StylistFailure {
  const StylistPermissionFailure({required super.message, super.code});
}

class StylistProviderFailure extends StylistFailure {
  const StylistProviderFailure({required super.message, super.code});
}

Future<T> stylistDataSourceOperation<T>(Future<T> Function() operation) async {
  try {
    return await operation();
  } on StylistException {
    rethrow;
  } on Failures catch (error) {
    throw fromFailure(error);
  } on PostgrestException catch (error) {
    if (error.code == 'PGRST116') {
      if (kDebugMode){
        developer.log(error.message);
      }
      throw StylistNotFoundException(code: error.code, cause: error);
    }
    if (error.code == '42501') {
      if (kDebugMode){
        developer.log(error.message);
      }
      throw StylistPermissionException(code: error.code, cause: error);
    }
    if (kDebugMode){
        developer.log(error.message);
      }
    throw StylistProviderException(
      message: error.message,
      code: error.code,
      cause: error,
    );
  } on SocketException catch (error) {
    throw StylistNetworkException(cause: error);
  } on TimeoutException catch (error) {
    throw StylistNetworkException(cause: error);
  } catch (error) {
    final text = error.toString().toLowerCase();
    if (text.contains('not found') || text.contains('pgrst116')) {
      if (kDebugMode){
        developer.log(error.toString());
      }
      throw StylistNotFoundException(cause: error);
    }
    if (text.contains('required') ||
        text.contains('invalid') ||
        text.contains('validation')) {
      if (kDebugMode){
        developer.log(error.toString());
      }
      throw StylistValidationException(cause: error);
    }
    if (text.contains('permission') ||
        text.contains('denied') ||
        text.contains('location')) {
      if (kDebugMode){
        developer.log(error.toString());
      }
      throw StylistPermissionException(cause: error);
    }
    if (kDebugMode){
        developer.log(error.toString());
      }
    throw StylistProviderException(cause: error);
  }
}

StylistException fromFailure(Failures error) {
  final text = error.message.toLowerCase();
  if (text.contains('required') ||
      text.contains('invalid') ||
      text.contains('validation') ||
      text.contains('greater than') ||
      text.contains('must be')) {
    return StylistValidationException(
      message: error.message,
      code: error.code,
      cause: error,
    );
  }
  if (text.contains('network') ||
      text.contains('internet') ||
      text.contains('reach') ||
      text.contains('socket') ||
      text.contains('timeout')) {
    return StylistNetworkException(
      message: error.message,
      code: error.code,
      cause: error,
    );
  }
  if (text.contains('not found')) {
    return StylistNotFoundException(
      message: error.message,
      code: error.code,
      cause: error,
    );
  }
  if (text.contains('permission') ||
      text.contains('access') ||
      text.contains('denied') ||
      text.contains('location')) {
    return StylistPermissionException(
      message: error.message,
      code: error.code,
      cause: error,
    );
  }
  return StylistProviderException(
    message: error.message,
    code: error.code,
    cause: error,
  );
}

Future<Either<Failures, T>> stylistRepositoryOperation<T>(
  Future<T> Function() operation,
) async {
  try {
    return Right(await operation());
  } on StylistException catch (error) {
    return Left(toFailure(error));
  } on Failures catch (error) {
    return Left(toFailure(fromFailure(error)));
  } catch (_) {
    return const Left(
      StylistProviderFailure(
        message: 'We could not complete this stylist request. Please try again.',
      ),
    );
  }
}

StylistFailure toFailure(StylistException error) {
  if (error is StylistValidationException) {
    return StylistValidationFailure(message: error.message, code: error.code);
  }
  if (error is StylistNetworkException) {
    return StylistNetworkFailure(message: error.message, code: error.code);
  }
  if (error is StylistNotFoundException) {
    return StylistNotFoundFailure(message: error.message, code: error.code);
  }
  if (error is StylistPermissionException) {
    return StylistPermissionFailure(message: error.message, code: error.code);
  }
  return StylistProviderFailure(message: error.message, code: error.code);
}

void requireValue(String value, String message) {
  if (value.trim().isEmpty) {
    throw StylistValidationException(message: message);
  }
}
