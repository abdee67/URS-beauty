import 'package:urs_beauty/api/stripe/stripe_api_service.dart';
import 'package:urs_beauty/features/payments/data/dataSources/payment_remote_data_source';
import 'package:urs_beauty/features/payments/data/models/payment_model.dart';

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final StripeApiService apiService;
  const PaymentRemoteDataSourceImpl({required this.apiService});

  @override
  Future<PaymentModel> createCardPayment(
    String bookingId,
    PaymentModel payment,
  ) {
    return apiService.createCardPayment(bookingId, payment);
  }

  @override
  Future<PaymentModel> confirmCardPayment(String transactionReference) {
    return apiService.confirmCardPayment(transactionReference);
  }

  @override
  Future<PaymentModel> handleCardPaymentFailure(String transactionReference) {
    return apiService.handleCardPaymentFailure(transactionReference);
  }

  @override
  Future<PaymentModel> getCardPaymentStatus(
    String paymentId,
    String bookingId,
  ) {
    return apiService.getCardPaymentStatus(paymentId, bookingId);
  }

  @override
  Future<PaymentModel> canclePendingCardPayment(String paymentId) {
    return apiService.canclePendingCardPayment(paymentId);
  }

  @override
  Future<PaymentModel> createBankTransferPayment(
    String bookingId,
    String proofUrl,
    String reference,
  ) {
    return apiService.createBankTransferPayment(bookingId, proofUrl, reference);
  }

  @override
  Future<PaymentModel> verfiyBankTransferPayment(
    String paymentId,
    bool isVerified,
  ) {
    return apiService.verfiyBankTransferPayment(paymentId, isVerified);
  }

  @override
  Future<PaymentModel> calculateRefund(String paymentId) {
    return apiService.calculateRefund(paymentId);
  }

  @override
  Future<PaymentModel> processRefundPayment(String paymentId) {
    return apiService.processRefundPayment(paymentId);
  }

  @override
  Future<PaymentModel> calculateRescheduleCost(
    String bookingId,
    String newServiceId,
  ) {
    return apiService.calculateRescheduleCost(bookingId, newServiceId);
  }

  @override
  Future<PaymentModel> processReschedulePayment(
    String bookingId,
    DateTime newDateTime,
    String newServiceId,
  ) {
    return apiService.processReschedulePayment(
      bookingId,
      newDateTime,
      newServiceId,
    );
  }
}
