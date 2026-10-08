import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/core/errors/exceptions/review_exceptions.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/reviews/domain/entity/review_entity.dart';

abstract class ReviewFailure extends Failures {
  const ReviewFailure({required super.message, super.code});
}

class ReviewValidationFailure extends ReviewFailure {
  const ReviewValidationFailure({required super.message, super.code});
}

class ReviewConflictFailure extends ReviewFailure {
  const ReviewConflictFailure({required super.message, super.code});
}

class ReviewNetworkFailure extends ReviewFailure {
  const ReviewNetworkFailure({required super.message, super.code});
}

class ReviewNotFoundFailure extends ReviewFailure {
  const ReviewNotFoundFailure({required super.message, super.code});
}

class ReviewPermissionFailure extends ReviewFailure {
  const ReviewPermissionFailure({required super.message, super.code});
}

class ReviewProviderFailure extends ReviewFailure {
  const ReviewProviderFailure({required super.message, super.code});
}

Future<T> reviewDataSourceOperation<T>(Future<T> Function() operation) async {
  try {
    return await operation();
  } on ReviewExceptions {
    rethrow;
  } on Failures catch (error) {
    throw fromFailure(error);
  } on PostgrestException catch (error) {
    if (error.code == 'PGRST116') {
      throw ReviewNotFoundException(code: error.code, cause: error);
    }
    if (error.code == '42501') {
      throw ReviewPermissionException(code: error.code, cause: error);
    }
    if (error.code == '23505') {
      throw ReviewConflictException(code: error.code, cause: error);
    }
    throw ReviewProviderException(
      message: error.message,
      code: error.code,
      cause: error,
    );
  } on SocketException catch (error) {
    throw ReviewNetworkException(cause: error);
  } on TimeoutException catch (error) {
    throw ReviewNetworkException(cause: error);
  } catch (error) {
    final text = error.toString().toLowerCase();
    if (text.contains('not found') || text.contains('pgrst116')) {
      throw ReviewNotFoundException(cause: error);
    }
    if (text.contains('already') ||
        text.contains('duplicate') ||
        text.contains('exist')) {
      throw ReviewConflictException(cause: error);
    }
    if (text.contains('required') ||
        text.contains('invalid') ||
        text.contains('rating')) {
      throw ReviewValidationException(cause: error);
    }
    throw ReviewProviderException(cause: error);
  }
}

ReviewExceptions fromFailure(Failures error) {
  final text = error.message.toLowerCase();
  if (text.contains('required') ||
      text.contains('invalid') ||
      text.contains('rating') ||
      text.contains('between')) {
    return ReviewValidationException(
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
    return ReviewNetworkException(
      message: error.message,
      code: error.code,
      cause: error,
    );
  }
  if (text.contains('already') ||
      text.contains('duplicate') ||
      text.contains('exist')) {
    return ReviewConflictException(
      message: error.message,
      code: error.code,
      cause: error,
    );
  }
  if (text.contains('not found')) {
    return ReviewNotFoundException(
      message: error.message,
      code: error.code,
      cause: error,
    );
  }
  if (text.contains('permission') ||
      text.contains('access') ||
      text.contains('denied')) {
    return ReviewPermissionException(
      message: error.message,
      code: error.code,
      cause: error,
    );
  }
  return ReviewProviderException(
    message: error.message,
    code: error.code,
    cause: error,
  );
}

Future<Either<Failures, T>> reviewRepositoryOperation<T>(
  Future<T> Function() operation,
) async {
  try {
    return Right(await operation());
  } on ReviewExceptions catch (error) {
    return Left(toFailure(error));
  } on Failures catch (error) {
    return Left(toFailure(fromFailure(error)));
  } catch (_) {
    return const Left(
      ReviewProviderFailure(
        message: 'We could not complete this review request. Please try again.',
      ),
    );
  }
}

ReviewFailure toFailure(ReviewExceptions error) {
  if (error is ReviewValidationException) {
    return ReviewValidationFailure(message: error.message, code: error.code);
  }
  if (error is ReviewConflictException) {
    return ReviewConflictFailure(message: error.message, code: error.code);
  }
  if (error is ReviewNetworkException) {
    return ReviewNetworkFailure(message: error.message, code: error.code);
  }
  if (error is ReviewNotFoundException) {
    return ReviewNotFoundFailure(message: error.message, code: error.code);
  }
  if (error is ReviewPermissionException) {
    return ReviewPermissionFailure(message: error.message, code: error.code);
  }
  return ReviewProviderFailure(message: error.message, code: error.code);
}

void requireValue(String value, String message) {
  if (value.trim().isEmpty) {
    throw ReviewValidationException(message: message);
  }
}

  void validateReview(ReviewEntity review) {
    if (review.bookingId.trim().isEmpty) {
      throw Failures(message: 'Booking ID is required');
    }

    if (review.customerId.trim().isEmpty) {
      throw Failures(message: 'Customer ID is required');
    }

    if (review.stylistId.trim().isEmpty) {
      throw Failures(message: 'Stylist ID is required');
    }

    if (review.rating < 1 || review.rating > 5) {
      throw Failures(message: 'Rating must be between 1 and 5');
    }
  }
