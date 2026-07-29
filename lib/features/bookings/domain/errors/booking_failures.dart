import 'package:urs_beauty/core/errors/failures.dart';

sealed class BookingFailure extends Failures {
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

class BookingResponseFailure extends BookingFailure {
  const BookingResponseFailure({required super.message, super.code});
}
