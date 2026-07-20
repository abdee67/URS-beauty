import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/error_handler.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/payments/data/dataSources/payment_remote_data_source.dart';
import 'package:urs_beauty/features/payments/data/models/payment_model.dart';
import 'package:urs_beauty/features/payments/domain/entity/payment_entity.dart';
import 'package:urs_beauty/features/payments/domain/repository/payment_repostiory.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  const PaymentRepositoryImpl({required this.paymentRemoteDataSource});

  final PaymentRemoteDataSource paymentRemoteDataSource;

  @override
  Future<Either<Failures, PaymentEntity>> createCardPayment(
    String bookingId,
    PaymentEntity payment,
  ) async {
    return repoErrorHnadler(() async {
      final result = await paymentRemoteDataSource.createCardPayment(
        bookingId,
        PaymentModel.fromEntity(payment),
      );
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failures, PaymentEntity>> confirmCardPayment(
    String transactionReference,
  ) async {
    return repoErrorHnadler(() async {
      final result = await paymentRemoteDataSource.confirmCardPayment(
        transactionReference,
      );
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failures, PaymentEntity>> handleCardPaymentFailure(
    String transactionReference,
  ) async {
    return repoErrorHnadler(() async {
      final result = await paymentRemoteDataSource.handleCardPaymentFailure(
        transactionReference,
      );
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failures, PaymentEntity>> createWalletPayment(
    String bookingId,
    PaymentEntity payment,
  ) async {
    return repoErrorHnadler(() async {
      final result = await paymentRemoteDataSource.createWalletPayment(
        bookingId,
        PaymentModel.fromEntity(payment),
      );
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failures, PaymentEntity>> confirmWalletPayment(
    String transactionReference,
  ) async {
    return repoErrorHnadler(() async {
      final result = await paymentRemoteDataSource.confirmWalletPayment(
        transactionReference,
      );
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failures, PaymentEntity>> handleWalletPaymentFailure(
    String transactionReference,
  ) async {
    return repoErrorHnadler(() async {
      final result = await paymentRemoteDataSource.handleWalletPaymentFailure(
        transactionReference,
      );
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failures, PaymentEntity>> receiveCashPayment(
    String bookingId,
  ) async {
    return repoErrorHnadler(() async {
      final result = await paymentRemoteDataSource.receiveCashPayment(
        bookingId,
      );
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failures, PaymentEntity>> customerConfirmCashPayment(
    String customerId,
    String bookingId,
  ) async {
    return repoErrorHnadler(() async {
      final result = await paymentRemoteDataSource.customerConfirmCashPayment(
        customerId,
        bookingId,
      );
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failures, PaymentEntity>> customerDisputeCashPayment(
    String customerId,
    String bookingId,
    String? note,
  ) async {
    return repoErrorHnadler(() async {
      final result = await paymentRemoteDataSource.customerDisputeCashPayment(
        customerId,
        bookingId,
        note,
      );
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failures, PaymentEntity>> getPaymentStatus(
    String paymentId,
    String bookingId,
  ) async {
    return repoErrorHnadler(() async {
      final result = await paymentRemoteDataSource.getPaymentStatus(
        paymentId,
        bookingId,
      );
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failures, PaymentEntity>> canclePendingCardPayment(
    String paymentId,
  ) async {
    return repoErrorHnadler(() async {
      final result = await paymentRemoteDataSource.canclePendingCardPayment(
        paymentId,
      );
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failures, PaymentEntity>> canclePendingWalletPayment(
    String paymentId,
  ) async {
    return repoErrorHnadler(() async {
      final result = await paymentRemoteDataSource.canclePendingWalletPayment(
        paymentId,
      );
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failures, PaymentEntity>> createBankTransferPayment(
    String bookingId,
    String proofUrl,
    String reference,
  ) async {
    return repoErrorHnadler(() async {
      final result = await paymentRemoteDataSource.createBankTransferPayment(
        bookingId,
        proofUrl,
        reference,
      );
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failures, PaymentEntity>> verfiyBankTransferPayment(
    String paymentId,
    bool isVerified,
  ) async {
    return repoErrorHnadler(() async {
      final result = await paymentRemoteDataSource.verfiyBankTransferPayment(
        paymentId,
        isVerified,
      );
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failures, PaymentEntity>> calculateRefund(
    String paymentId,
  ) async {
    return repoErrorHnadler(() async {
      final result = await paymentRemoteDataSource.calculateRefund(paymentId);
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failures, PaymentEntity>> processRefundCardPayment(
    String paymentId,
  ) async {
    return repoErrorHnadler(() async {
      final result = await paymentRemoteDataSource.processRefundCardPayment(
        paymentId,
      );
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failures, PaymentEntity>> processRefundWalletPayment(
    String paymentId,
  ) async {
    return repoErrorHnadler(() async {
      final result = await paymentRemoteDataSource.processRefundWalletPayment(
        paymentId,
      );
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failures, PaymentEntity>> calculateRescheduleCost(
    String bookingId,
    String newServiceId,
  ) async {
    return repoErrorHnadler(() async {
      final result = await paymentRemoteDataSource.calculateRescheduleCost(
        bookingId,
        newServiceId,
      );
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failures, PaymentEntity>> processReschedulePayment(
    String bookingId,
    DateTime newDateTime,
    String newServiceId,
  ) async {
    return repoErrorHnadler(() async {
      final result = await paymentRemoteDataSource.processReschedulePayment(
        bookingId,
        newDateTime,
        newServiceId,
      );
      return result.toEntity();
    });
  }

}
