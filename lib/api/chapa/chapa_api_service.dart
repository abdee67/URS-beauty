import 'package:urs_beauty/api/api_service.dart';
import 'package:urs_beauty/features/payments/data/models/payment_model.dart';
import 'package:urs_beauty/features/payments/domain/entity/payment_entity.dart';

class ChapaApiService extends ApiService {
  ChapaApiService({super.client});

  Future<PaymentModel> createWalletPayment(
    String bookingId,
    PaymentModel payment,
  ) async {
    final response = await invokeFunction(
      'create-chapa-payment',
      body: <String, dynamic>{
        'booking_id': bookingId,
        'payment_method': payment.paymentMethod.apiValue,
        'payment_type': payment.paymentType.apiValue,
        'client_reported_amount': payment.amount,
        'currency': payment.currency,
        'metadata': payment.metaData,
      },
    );

    return _mapFunctionPaymentResponse(response, fallbackBookingId: bookingId);
  }

  Future<PaymentModel> confirmWalletPayment(String paymentReference) async {
    final response = await invokeFunction(
      'verify-chapa-payment',
      body: <String, dynamic>{'payment_reference': paymentReference},
    );

    return _mapFunctionPaymentResponse(response);
  }

  Future<PaymentModel> handleWalletPaymentFailure(
    String paymentReference,
  ) async {
    final response = await invokeFunction(
      'cancel-chapa-payment',
      body: <String, dynamic>{
        'payment_reference': paymentReference,
        'reason': 'payment_cancelled_from_app',
      },
    );

    return _mapFunctionPaymentResponse(response);
  }

  Future<PaymentModel> canclePendingWalletPayment(String paymentId) async {
    final response = await invokeFunction(
      'cancel-chapa-payment',
      body: <String, dynamic>{
        'payment_reference': paymentId,
        'reason': 'pending_payment_cancelled',
      },
    );

    return _mapFunctionPaymentResponse(response);
  }

  Future<PaymentModel> processRefundWalletPayment(String paymentId) async {
    final response = await invokeFunction(
      'process-refund-chapa-payment',
      body: <String, dynamic>{'payment_id': paymentId},
    );

    return _mapFunctionPaymentResponse(response);
  }

  PaymentModel _mapFunctionPaymentResponse(
    Map<String, dynamic> response, {
    String? fallbackBookingId,
  }) {
    final paymentPayload = response['payment'] != null
        ? requireMap(response['payment'], context: 'payment')
        : response;

    final mergedPayload = <String, dynamic>{
      ...paymentPayload,
      if (fallbackBookingId != null &&
          (paymentPayload['booking_id']?.toString().trim().isEmpty ?? true))
        'booking_id': fallbackBookingId,
      if (response['payment_intent_client_secret'] != null)
        'payment_intent_client_secret':
            response['payment_intent_client_secret'],
      if (response['booking_status'] != null)
        'booking_status': response['booking_status'],
      if (response['booking_payment_status'] != null)
        'booking_payment_status': response['booking_payment_status'],
      if (response['refundable_amount'] != null)
        'refundable_amount': response['refundable_amount'],
      if (response['refunded_amount'] != null)
        'refunded_amount': response['refunded_amount'],
      if (response['adjustment_amount'] != null)
        'adjustment_amount': response['adjustment_amount'],
      if (response['failure_reason'] != null)
        'failure_reason': response['failure_reason'],
    };

    if (response['refund_quote'] is Map) {
      final refundQuote = Map<String, dynamic>.from(
        response['refund_quote'] as Map,
      );
      if (mergedPayload['refundable_amount'] == null) {
        mergedPayload['refundable_amount'] = refundQuote['refundable_amount'];
      }
      mergedPayload['refund_percentage'] = refundQuote['refund_percentage'];
    }

    return PaymentModel.fromJson(mergedPayload);
  }
}
