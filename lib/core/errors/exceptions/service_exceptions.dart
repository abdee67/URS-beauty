import 'package:urs_beauty/core/errors/exceptions.dart';

class ServiceException extends AppExceptions {
  const ServiceException({required super.message, super.code, super.cause});
}

class ServiceValidationException extends ServiceException {
  const ServiceValidationException({required super.message, super.code, super.cause});
}

class ServiceNetworkException extends ServiceException {
  const ServiceNetworkException({
    super.message = 'We could not load beauty services. Please try again.',
    super.code,
    super.cause,
  });
}

class ServiceNotFoundException extends ServiceException {
  const ServiceNotFoundException({
    super.message = 'The requested beauty service was not found.',
    super.code,
    super.cause,
  });
}

class ServiceResponseException extends ServiceException {
  const ServiceResponseException({
    super.message = 'The services response was invalid. Please try again.',
    super.code,
    super.cause,
  });
}
