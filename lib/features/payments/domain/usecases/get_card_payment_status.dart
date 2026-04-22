import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/payments/domain/entity/payment_entity.dart';
import 'package:urs_beauty/features/payments/domain/repository/payment_repostiory';

class GetCardPaymentStatusUseCase {
  const GetCardPaymentStatusUseCase({required this.paymentRepository});

  final PaymentRepository paymentRepository;

  Future<Either<Failures, PaymentEntity>> call(
    String paymentId,
    String bookingId,
  ) async {
    return await paymentRepository.getCardPaymentStatus(paymentId, bookingId);
  }
}
