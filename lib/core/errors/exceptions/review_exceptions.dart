import 'package:urs_beauty/core/errors/exceptions.dart';

class ReviewExceptions extends AppExceptions {
  const ReviewExceptions({required super.message, super.code, super.cause});
}

class ReviewNotFoundException extends ReviewExceptions {
  const ReviewNotFoundException({
    super.message = 'We could not find this review.',
    super.code,
    super.cause,
  });
}

class ReviewValidationException extends ReviewExceptions {
  const ReviewValidationException({
    super.message =
        'This review is not valid. Please check your input and try again.',
    super.code,
    super.cause,
  });
}

class ReviewConflictException extends ReviewExceptions {
  const ReviewConflictException({
    super.message =
        'A review already exists for this booking. Only one review per booking is allowed.',
    super.code,
    super.cause,
  });
}

class ReviewNetworkException extends ReviewExceptions {
  const ReviewNetworkException({
    super.message = 'We could not reach the review service. Please try again.',
    super.code,
    super.cause,
  });
}

class ReviewPermissionException extends ReviewExceptions {
  const ReviewPermissionException({
    super.message = 'You do not have permission to perform this review action.',
    super.code,
    super.cause,
  });
}

class ReviewProviderException extends ReviewExceptions {
  const ReviewProviderException({
    super.message = 'The review service returned an unexpected response.',
    super.code,
    super.cause,
  });
}
