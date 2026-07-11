import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/payments/domain/entity/payment_entity.dart';
import 'package:urs_beauty/features/payments/domain/repository/payment_repostiory.dart';

class CancelPendingCardPaymentUseCase {
  const CancelPendingCardPaymentUseCase({required this.paymentRepository});

  final PaymentRepository paymentRepository;

  Future<Either<Failures, PaymentEntity>> call(String paymentId) async {
    return await paymentRepository.canclePendingCardPayment(paymentId);
  }
}
class CancelPendingWalletPaymentUseCase {
  const CancelPendingWalletPaymentUseCase({required this.paymentRepository});

  final PaymentRepository paymentRepository;

  Future<Either<Failures, PaymentEntity>> call(String paymentId) async {
    return await paymentRepository.canclePendingWalletPayment(paymentId);
  }
}
