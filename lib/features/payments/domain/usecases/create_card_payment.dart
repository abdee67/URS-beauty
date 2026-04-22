import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/payments/domain/entity/payment_entity.dart';
import 'package:urs_beauty/features/payments/domain/repository/payment_repostiory';

class CreateCardPaymentUseCase {
  const CreateCardPaymentUseCase({required this.paymentRepository});

  final PaymentRepository paymentRepository;

  Future<Either<Failures, PaymentEntity>> call(
    String bookingId,
    PaymentEntity payment,
  ) async {
    return await paymentRepository.createCardPayment(bookingId, payment);
  }
}
