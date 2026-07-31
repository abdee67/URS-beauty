import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/exceptions/payment_exceptions.dart';
import 'package:urs_beauty/core/errors/failures.dart';

abstract class PaymentFailure extends Failures {
  const PaymentFailure({required super.message, super.code});
}

class PaymentValidationFailure extends PaymentFailure {
  const PaymentValidationFailure({required super.message, super.code});
}

class PaymentNetworkFailure extends PaymentFailure {
  const PaymentNetworkFailure({required super.message, super.code});
}

class PaymentDeclinedFailure extends PaymentFailure {
  const PaymentDeclinedFailure({required super.message, super.code});
}

class PaymentNotFoundFailure extends PaymentFailure {
  const PaymentNotFoundFailure({required super.message, super.code});
}

class PaymentPermissionFailure extends PaymentFailure {
  const PaymentPermissionFailure({required super.message, super.code});
}

class PaymentProviderFailure extends PaymentFailure {
  const PaymentProviderFailure({required super.message, super.code});
}

Future<T> paymentDataSourceOperation<T>(Future<T> Function() operation) async {
  try {
    return await operation();
  } on PaymentException {
    rethrow;
  } on Failures catch (error) {
    throw fromFailure(error);
  } on SocketException catch (error) {
    throw PaymentNetworkException(cause: error);
  } on TimeoutException catch (error) {
    throw PaymentNetworkException(cause: error);
  } catch (error) {
    final text = error.toString().toLowerCase();
    if (text.contains('declin') || text.contains('insufficient funds')) {
      throw PaymentDeclinedException(cause: error);
    }
    if (text.contains('not found') || text.contains('pgrst116')) {
      throw PaymentNotFoundException(cause: error);
    }
    throw PaymentProviderException(cause: error);
  }
}

PaymentException fromFailure(Failures error) {
  final text = error.message.toLowerCase();
  if (text.contains('required') || text.contains('invalid')) {
    return PaymentValidationException(
      message: error.message,
      code: error.code,
      cause: error,
    );
  }
  if (text.contains('network') ||
      text.contains('internet') ||
      text.contains('reach')) {
    return PaymentNetworkException(
      message: error.message,
      code: error.code,
      cause: error,
    );
  }
  if (text.contains('declin') || text.contains('insufficient')) {
    return PaymentDeclinedException(
      message: error.message,
      code: error.code,
      cause: error,
    );
  }
  if (text.contains('not found')) {
    return PaymentNotFoundException(
      message: error.message,
      code: error.code,
      cause: error,
    );
  }
  return PaymentProviderException(
    message: error.message,
    code: error.code,
    cause: error,
  );
}

Future<Either<Failures, T>> paymentDataRepositoryRunOperation<T>(
  Future<T> Function() operation,
) async {
  try {
    return Right(await operation());
  } on PaymentException catch (error) {
    return Left(toFailure(error));
  } on Failures catch (error) {
    return Left(
      PaymentProviderFailure(message: error.message, code: error.code),
    );
  } catch (_) {
    return const Left(
      PaymentProviderFailure(
        message: 'We could not complete the payment request. Please try again.',
      ),
    );
  }
}

PaymentFailure toFailure(PaymentException error) {
  if (error is PaymentValidationException) {
    return PaymentValidationFailure(message: error.message, code: error.code);
  }
  if (error is PaymentNetworkException) {
    return PaymentNetworkFailure(message: error.message, code: error.code);
  }
  if (error is PaymentDeclinedException) {
    return PaymentDeclinedFailure(message: error.message, code: error.code);
  }
  if (error is PaymentNotFoundException) {
    return PaymentNotFoundFailure(message: error.message, code: error.code);
  }
  if (error is PaymentPermissionException) {
    return PaymentPermissionFailure(message: error.message, code: error.code);
  }
  return PaymentProviderFailure(message: error.message, code: error.code);
}
