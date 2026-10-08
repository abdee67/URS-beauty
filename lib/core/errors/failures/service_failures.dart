import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/core/errors/exceptions/service_exceptions.dart';
import 'package:urs_beauty/core/errors/failures.dart';

abstract class ServiceFailure extends Failures {
  const ServiceFailure({required super.message, super.code});
}

class ServiceValidationFailure extends ServiceFailure {
  const ServiceValidationFailure({required super.message, super.code});
}

class ServiceNetworkFailure extends ServiceFailure {
  const ServiceNetworkFailure({required super.message, super.code});
}

class ServiceNotFoundFailure extends ServiceFailure {
  const ServiceNotFoundFailure({required super.message, super.code});
}

class ServiceResponseFailure extends ServiceFailure {
  const ServiceResponseFailure({required super.message, super.code});
}

Future<Either<Failures, T>> serviceRepositoryOperation<T>(
  Future<T> Function() operation,
) async {
  try {
    return Right(await operation());
  } on ServiceException catch (error) {
    return Left(toFailure(error));
  } on Failures catch (error) {
    return Left(
      ServiceResponseFailure(message: error.message, code: error.code),
    );
  } catch (_) {
    return const Left(
      ServiceResponseFailure(
        message: 'We could not load beauty services. Please try again.',
      ),
    );
  }
}

ServiceFailure toFailure(ServiceException error) {
  if (error is ServiceValidationException) {
    return ServiceValidationFailure(message: error.message, code: error.code);
  }
  if (error is ServiceNetworkException) {
    return ServiceNetworkFailure(message: error.message, code: error.code);
  }
  if (error is ServiceNotFoundException) {
    return ServiceNotFoundFailure(message: error.message, code: error.code);
  }
  return ServiceResponseFailure(message: error.message, code: error.code);
}

Future<T> serviceDataSourceOperation<T>(Future<T> Function() operation) async {
  try {
    return await operation();
  } on ServiceException {
    rethrow;
  } on PostgrestException catch (e) {
    if (e.code == 'PGRST116') {
      throw ServiceNotFoundException(code: e.code, cause: e);
    }
    throw ServiceResponseException(message: e.message, code: e.code, cause: e);
  } on SocketException catch (e) {
    throw ServiceNetworkException(cause: e);
  } on TimeoutException catch (e) {
    throw ServiceNetworkException(cause: e);
  } catch (e) {
    throw ServiceResponseException(cause: e);
  }
}

void requireValue(String value, String message) {
  if (value.trim().isEmpty) {
    throw ServiceValidationException(message: message);
  }
}
