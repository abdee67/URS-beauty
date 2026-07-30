import 'package:urs_beauty/core/errors/exceptions.dart';

class PaymentException extends AppExceptions {
  const PaymentException({required super.message, super.code, super.cause});
}

class PaymentValidationException extends PaymentException {
  const PaymentValidationException({required super.message, super.code, super.cause});
}

class PaymentNetworkException extends PaymentException {
  const PaymentNetworkException({
    super.message = 'We could not reach the payment service. Please try again.',
    super.code,
    super.cause,
  });
}

class PaymentDeclinedException extends PaymentException {
  const PaymentDeclinedException({
    super.message = 'Your payment was declined. Please try another method.',
    super.code,
    super.cause,
  });
}

class PaymentNotFoundException extends PaymentException {
  const PaymentNotFoundException({
    super.message = 'The payment could not be found.',
    super.code,
    super.cause,
  });
}

class PaymentPermissionException extends PaymentException {
  const PaymentPermissionException({
    super.message = 'You do not have permission to perform this payment action.',
    super.code,
    super.cause,
  });
}

class PaymentProviderException extends PaymentException {
  const PaymentProviderException({
    super.message = 'The payment provider returned an unexpected response.',
    super.code,
    super.cause,
  });
}
