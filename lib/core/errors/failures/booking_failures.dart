import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/core/errors/exceptions.dart';
import 'package:urs_beauty/core/errors/exceptions/booking_exceptions.dart';
import 'package:urs_beauty/core/errors/failures.dart';

abstract class BookingFailure extends Failures {
  const BookingFailure({required super.message, super.code});
}

class BookingValidationFailure extends BookingFailure {
  const BookingValidationFailure({required super.message, super.code});
}

class BookingConflictFailure extends BookingFailure {
  const BookingConflictFailure({required super.message, super.code});
}

class BookingNotFoundFailure extends BookingFailure {
  const BookingNotFoundFailure({required super.message, super.code});
}

class BookingPermissionFailure extends BookingFailure {
  const BookingPermissionFailure({required super.message, super.code});
}

class BookingNetworkFailure extends BookingFailure {
  const BookingNetworkFailure({required super.message, super.code});
}

class BookingResponseFailure extends BookingFailure {
  const BookingResponseFailure({required super.message, super.code});
}
 void requireValue(String value, String message) {
    if (value.trim().isEmpty) {
      throw BookingValidationException(message: message);
    }
  }
   Future<T> bookingDataSourceOperation<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on AppExceptions {
      rethrow;
    } catch (error, stackTrace) {
      throw mapBookingException(error, stackTrace);
    }
  }

  BookingException mapBookingException(Object error, StackTrace stackTrace) {
    if (error is BookingException) return error;
    if (error is SocketException || error is TimeoutException) {
      return BookingNetworkException(cause: error);
    }
    if (error is PostgrestException) {
      if (error.code == '42501'){
        return BookingPermissionException(cause: error, code: error.code);
      }else if (error.code == 'P0001' || error.code == '23P01'){
        return BookingConflictException(cause: error, code: error.code);
      }else if (error.code == 'PGRST116'){
        return BookingNotFoundException(cause: error, code: error.code);
      }
      return BookingResponseException(
        message: 'This booking service could not be process this request',
        code: error.code,
        cause: error,
        );
  }
  if (error is FunctionException){
    final text = error.toString().toLowerCase();
    if (text.contains('conflict') || text.contains('unavailable') ||
        text.contains('not available') || text.contains('already booked')){
      return BookingConflictException(
        cause: error,
      );
    }
  }
  return BookingResponseException(
    message: 'This booking service could not be process this request',
    cause: error,
  );
  }
   Future<Either<Failures, T>> bookingRepositoryOperation<T>(
    Future<T> Function() operation,
  ) async {
    try {
      return Right(await operation());
    } on BookingException catch (exception) {
      return Left(toBookingFailure(exception));
    } catch (error) {
      return const Left(
        BookingResponseFailure(
          message: 'We could not complete this booking request. Please try again.',
        ),
      );
    }
  }

  BookingFailure toBookingFailure(BookingException exception) {
    if (exception is BookingValidationException) {
      return BookingValidationFailure(
        message: exception.message,
        code: exception.code,
      );
    }
    if (exception is BookingConflictException) {
      return BookingConflictFailure(
        message: exception.message,
        code: exception.code,
      );
    }
    if (exception is BookingNotFoundException) {
      return BookingNotFoundFailure(
        message: exception.message,
        code: exception.code,
      );
    }
    if (exception is BookingPermissionException) {
      return BookingPermissionFailure(
        message: exception.message,
        code: exception.code,
      );
    }
    if (exception is BookingNetworkException) {
      return BookingNetworkFailure(
        message: exception.message,
        code: exception.code,
      );
    }
    return BookingResponseFailure(
      message: exception.message,
      code: exception.code,
    );
  }