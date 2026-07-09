import 'package:urs_beauty/features/payments/data/models/payment_model.dart';

abstract class PaymentRemoteDataSource {
  Future<PaymentModel> createCardPayment(
    String bookingId,
    PaymentModel payment,
  );
  Future<PaymentModel> handleCardPaymentFailure(String transactionReference);

  Future<PaymentModel> getPaymentStatus(String paymentId, String bookingId);
  Future<PaymentModel> processRefundCardPayment(String paymentId);
  Future<PaymentModel> canclePendingCardPayment(String paymentId);
  Future<PaymentModel> confirmCardPayment(String transactionReference);

  //WALLET(CHAPA) PAYMENT
  Future<PaymentModel> createWalletPayment(
    String bookingId,
    PaymentModel payment,
  );
  Future<PaymentModel> confirmWalletPayment(String transactionReference);
  Future<PaymentModel> handleWalletPaymentFailure(String transactionReference);
  Future<PaymentModel> canclePendingWalletPayment(String paymentId);
  Future<PaymentModel> processRefundWalletPayment(String paymentId);

  //==CASH PAYMENT==
  Future<PaymentModel> receiveCashPayment(String bookingId);
  Future<PaymentModel> customerConfirmCashPayment(
    String customerId,
    String bookingId,
  );
  Future<PaymentModel> customerDisputeCashPayment(
    String customerId,
    String bookingId,
    String? note,
  );

  //== BANK TRANSFER PAYMENT=====
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
