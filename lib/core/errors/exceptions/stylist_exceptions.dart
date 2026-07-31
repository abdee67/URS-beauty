import 'package:urs_beauty/core/errors/exceptions.dart';

class StylistException extends AppExceptions {
  const StylistException({required super.message, super.code, super.cause});
}

class StylistValidationException extends StylistException {
  const StylistValidationException({
    super.message =
        'The stylist request is not valid. Please check your input and try again.',
    super.code,
    super.cause,
  });
}

class StylistNetworkException extends StylistException {
  const StylistNetworkException({
    super.message = 'We could not reach the stylist service. Please try again.',
    super.code,
    super.cause,
  });
}

class StylistNotFoundException extends StylistException {
  const StylistNotFoundException({
    super.message = 'We could not find the requested stylist.',
    super.code,
    super.cause,
  });
}

class StylistPermissionException extends StylistException {
  const StylistPermissionException({
    super.message = 'You do not have permission to perform this stylist action.',
    super.code,
    super.cause,
  });
}

class StylistProviderException extends StylistException {
  const StylistProviderException({
    super.message = 'The stylist service returned an unexpected response.',
    super.code,
    super.cause,
  });
}
