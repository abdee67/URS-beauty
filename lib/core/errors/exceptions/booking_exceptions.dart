import 'package:urs_beauty/core/errors/exceptions.dart';

abstract class BookingException extends AppExceptions {
  const BookingException({required super.message, super.code, super.cause});
}

class BookingValidationException extends BookingException {
  const BookingValidationException({
    required super.message,
    super.code,
    super.cause,
  });
}

class BookingConflictException extends BookingException {
  const BookingConflictException({
    super.message =
        'This appointment time is no longer available. Please choose another time.',
    super.code,
    super.cause,
  });
}

class BookingNotFoundException extends BookingException {
  const BookingNotFoundException({
    super.message = 'This booking could not be found.',
    super.code,
    super.cause,
  });
}

class BookingPermissionException extends BookingException {
  const BookingPermissionException({
    super.message = 'You do not have access to this booking.',
    super.code,
    super.cause,
  });
}

class BookingNetworkException extends BookingException {
  const BookingNetworkException({
    super.message = 'We could not reach the booking service. Please try again.',
    super.code,
    super.cause,
  });
}

class BookingResponseException extends BookingException {
  const BookingResponseException({
    super.message =
        'The booking service returned an unexpected response. Please try again.',
    super.code,
    super.cause,
  });
}
