import 'package:urs_beauty/features/payments/data/models/payment_model.dart';

abstract class PaymentRemoteDataSource {
  Future<PaymentModel> createCardPayment(
    String bookingId,
    PaymentModel payment,
  );
  Future<PaymentModel> createWalletPayment(
    String bookingId,
    PaymentModel payment,
  );

  Future<PaymentModel> confirmCardPayment(String transactionReference);
  Future<PaymentModel> confirmWalletPayment(String transactionReference);

  Future<PaymentModel> handleCardPaymentFailure(String transactionReference);
  Future<PaymentModel> handleWalletPaymentFailure(String transactionReference);

  Future<PaymentModel> getPaymentStatus(String paymentId, String bookingId);

  Future<PaymentModel> canclePendingCardPayment(String paymentId);
  Future<PaymentModel> canclePendingWalletPayment(String paymentId);

  Future<PaymentModel> createBankTransferPayment(
    String bookingId,
    String proofUrl,
    String reference,
  );

  Future<PaymentModel> verfiyBankTransferPayment(
    String paymentId,
    bool isVerified,
  );

  Future<PaymentModel> calculateRefund(String paymentId);

  Future<PaymentModel> processRefundCardPayment(String paymentId);
  Future<PaymentModel> processRefundWalletPayment(String paymentId);

  Future<PaymentModel> calculateRescheduleCost(
    String bookingId,
    String newServiceId,
  );

  Future<PaymentModel> processReschedulePayment(
    String bookingId,
    DateTime newDateTime,
    String newServiceId,
  );
}
