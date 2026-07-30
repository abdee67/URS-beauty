import 'dart:async';

import 'package:urs_beauty/api/cash/cash_payment_api_service.dart';
import 'package:urs_beauty/api/stripe/stripe_api_service.dart';
import 'package:urs_beauty/api/chapa/chapa_api_service.dart';
import 'package:urs_beauty/core/errors/failures/payment_failures.dart';
import 'package:urs_beauty/features/payments/data/dataSources/payment_remote_data_source.dart';
import 'package:urs_beauty/features/payments/data/models/payment_model.dart';

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final StripeApiService stripeApiService;
  final ChapaApiService chapaApiService;
  final CashPaymentApiService cashPaymentApiService;
  const PaymentRemoteDataSourceImpl({
    required this.stripeApiService,
    required this.chapaApiService,
    required this.cashPaymentApiService,
  });

  //===STRIPE PAYMENT====

  @override
  Future<PaymentModel> createCardPayment(
    String bookingId,
    PaymentModel payment,
  ) {
    return paymentDataSourceOperation(() => stripeApiService.createCardPayment(bookingId, payment));
  }

  @override
  Future<PaymentModel> confirmCardPayment(String transactionReference) {
    return paymentDataSourceOperation(() => stripeApiService.confirmCardPayment(transactionReference));
  }

  @override
  Future<PaymentModel> handleCardPaymentFailure(String transactionReference) {
    return paymentDataSourceOperation(() => stripeApiService.handleCardPaymentFailure(transactionReference));
  }

  @override
  Future<PaymentModel> canclePendingCardPayment(String paymentId) {
    return paymentDataSourceOperation(() => stripeApiService.canclePendingCardPayment(paymentId));
  }

  //WALLET(CHAPA) PAYMENT

  @override
  Future<PaymentModel> createWalletPayment(
    String bookingId,
    PaymentModel payment,
  ) {
    return paymentDataSourceOperation(() => chapaApiService.createWalletPayment(bookingId, payment));
  }

  @override
  Future<PaymentModel> canclePendingWalletPayment(String paymentId) {
    return paymentDataSourceOperation(() => chapaApiService.canclePendingWalletPayment(paymentId));
  }

  @override
  Future<PaymentModel> confirmWalletPayment(String transactionReference) {
    return paymentDataSourceOperation(() => chapaApiService.confirmWalletPayment(transactionReference));
  }

  @override
  Future<PaymentModel> handleWalletPaymentFailure(String transactionReference) {
    return paymentDataSourceOperation(() => chapaApiService.handleWalletPaymentFailure(transactionReference));
  }
  //===CASH PAYMENT===

  @override
  Future<PaymentModel> receiveCashPayment(String bookingId) {
    return paymentDataSourceOperation(() => cashPaymentApiService.receiveCashPayment(bookingId));
  }

  @override
  Future<PaymentModel> customerConfirmCashPayment(
    String customerId,
    String bookingId,
  ) {
    return paymentDataSourceOperation(() => cashPaymentApiService.customerConfirmCashPayment(
      customerId,
      bookingId,
    ));
  }

  @override
  Future<PaymentModel> customerDisputeCashPayment(
    String customerId,
    String bookingId,
    String? note,
  ) {
    return paymentDataSourceOperation(() => cashPaymentApiService.customerDisputeCashPayment(
      customerId,
      bookingId,
      note,
    ));
  }
  //====BANK TRANSFER PAYMENT====

  @override
  Future<PaymentModel> createBankTransferPayment(
    String bookingId,
    String proofUrl,
    String reference,
  ) {
    return paymentDataSourceOperation(() => stripeApiService.createBankTransferPayment(
      bookingId,
      proofUrl,
      reference,
    ));
  }

  @override
  Future<PaymentModel> verfiyBankTransferPayment(
    String paymentId,
    bool isVerified,
  ) {
    return paymentDataSourceOperation(() => stripeApiService.verfiyBankTransferPayment(paymentId, isVerified));
  }

  @override
  Future<PaymentModel> getPaymentStatus(String paymentId, String bookingId) {
    return paymentDataSourceOperation(() => stripeApiService.getPaymentStatus(paymentId, bookingId));
  }

  @override
  Future<PaymentModel> calculateRefund(String paymentId) {
    return paymentDataSourceOperation(() => stripeApiService.calculateRefund(paymentId));
  }

  @override
  Future<PaymentModel> processRefundCardPayment(String paymentId) {
    return paymentDataSourceOperation(() => stripeApiService.processRefundCardPayment(paymentId));
  }

  @override
  Future<PaymentModel> processRefundWalletPayment(String paymentId) {
    return paymentDataSourceOperation(() => chapaApiService.processRefundWalletPayment(paymentId));
  }

  @override
  Future<PaymentModel> calculateRescheduleCost(
    String bookingId,
    String newServiceId,
  ) {
    return paymentDataSourceOperation(() => stripeApiService.calculateRescheduleCost(bookingId, newServiceId));
  }

  @override
  Future<PaymentModel> processReschedulePayment(
    String bookingId,
    DateTime newDateTime,
    String newServiceId,
  ) {
    return paymentDataSourceOperation(() => stripeApiService.processReschedulePayment(
      bookingId,
      newDateTime,
      newServiceId,
    ));
  }


}
