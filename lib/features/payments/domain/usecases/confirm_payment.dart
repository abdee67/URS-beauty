import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/payments/domain/entity/payment_entity.dart';
import 'package:urs_beauty/features/payments/domain/repository/payment_repostiory.dart';

class ConfirmCardPaymentUseCase {
  const ConfirmCardPaymentUseCase({required this.paymentRepository});

  final PaymentRepository paymentRepository;

  Future<Either<Failures, PaymentEntity>> call(String paymentReference) async {
    return await paymentRepository.confirmCardPayment(paymentReference);
  }
}

class ConfirmWalletPaymentUseCase {
  const ConfirmWalletPaymentUseCase({required this.paymentRepository});

  final PaymentRepository paymentRepository;

  Future<Either<Failures, PaymentEntity>> call(String paymentReference) async {
    return await paymentRepository.confirmWalletPayment(paymentReference);
  }
}

class CustomerConfirmCashPayment {
  const CustomerConfirmCashPayment({required this.paymentRepository});

  final PaymentRepository paymentRepository;

  Future<Either<Failures, PaymentEntity>> call(
    String customerId,
    String bookingId,
  ) async {
    return await paymentRepository.customerConfirmCashPayment(
      customerId,
      bookingId,
    );
  }
}
