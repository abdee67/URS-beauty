import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/payments/domain/entity/payment_entity.dart';
import 'package:urs_beauty/features/payments/domain/repository/payment_repostiory.dart';

class HandleCardPaymentFailureUseCase {
  const HandleCardPaymentFailureUseCase({required this.paymentRepository});

  final PaymentRepository paymentRepository;

  Future<Either<Failures, PaymentEntity>> call(String paymentReference) async {
    return await paymentRepository.handleCardPaymentFailure(paymentReference);
  }
}

class HandleWalletPaymentFailureUseCase {
  const HandleWalletPaymentFailureUseCase({required this.paymentRepository});

  final PaymentRepository paymentRepository;
  Future<Either<Failures, PaymentEntity>> call(String paymentReference) async {
    return await paymentRepository.handleWalletPaymentFailure(paymentReference);
  }
}

class CustomerDisputeCashPayment {
  const CustomerDisputeCashPayment({required this.paymentRepository});

  final PaymentRepository paymentRepository;

  Future<Either<Failures, PaymentEntity>> call(
    String customerId,
    String bookingId,
    String? note,
  ) async {
    return await paymentRepository.customerDisputeCashPayment(
      customerId,
      bookingId,
      note,
    );
  }
}
