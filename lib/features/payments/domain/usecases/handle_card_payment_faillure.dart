import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/payments/domain/entity/payment_entity.dart';
import 'package:urs_beauty/features/payments/domain/repository/payment_repostiory';

class HandleCardPaymentFailureUseCase {
  const HandleCardPaymentFailureUseCase({required this.paymentRepository});

  final PaymentRepository paymentRepository;

  Future<Either<Failures, PaymentEntity>> call(
    String paymentReference,
  ) async {
    return await paymentRepository.handleCardPaymentFailure(paymentReference);
  }
}
