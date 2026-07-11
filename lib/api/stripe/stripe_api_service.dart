import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/api/api_service.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/payments/data/models/payment_model.dart';
import 'package:urs_beauty/features/payments/domain/entity/payment_entity.dart';

class StripeApiService extends ApiService {
  StripeApiService({super.client});

  static const String _paymentColumns =
      'id, booking_id, customer_id, payment_method, payment_type, status, '
      'amount, currency, transaction_reference, payment_proof_url, metadata, '
      'idempotency_key, stripe_payment_intent_id, stripe_checkout_session_id, '
      'failure_reason, refundable_amount, refunded_amount, adjustment_amount, '
      'paid_at, verified_at, created_at, updated_at';

  Future<PaymentModel> createCardPayment(
    String bookingId,
    PaymentModel payment,
  ) async {
    final response = await invokeFunction(
      'create-card-payment',
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

  Future<PaymentModel> confirmCardPayment(String paymentReference) async {
    final response = await invokeFunction(
      'verify-card-payment',
      body: <String, dynamic>{'payment_reference': paymentReference},
    );

    return _mapFunctionPaymentResponse(response);
  }


  Future<PaymentModel> handleCardPaymentFailure(String paymentReference) async {
    final response = await invokeFunction(
      'cancel-card-payment',
      body: <String, dynamic>{
        'payment_reference': paymentReference,
        'reason': 'payment_cancelled_from_app',
      },
    );

    return _mapFunctionPaymentResponse(response);
  }

  Future<PaymentModel> getPaymentStatus(
    String paymentId,
    String bookingId,
  ) async {
    try {
      final response = await client
          .from('payments')
          .select(_paymentColumns)
          .eq('id', paymentId)
          .eq('booking_id', bookingId)
          .maybeSingle(); 

      if (response == null) {
        throw Failures(message: 'Payment not found.');
      }

      return PaymentModel.fromJson(Map<String, dynamic>.from(response));
    } on PostgrestException catch (error) {
      throw Failures(message: error.message);
    } catch (error) {
      if (error is Failures) {
        rethrow;
      }
      throw Failures(message: error.toString());
    }
  }

  Future<PaymentModel> canclePendingCardPayment(String paymentId) async {
    final response = await invokeFunction(
      'cancel-card-payment',
      body: <String, dynamic>{
        'payment_reference': paymentId,
        'reason': 'pending_payment_cancelled',
      },
    );

    return _mapFunctionPaymentResponse(response);
  }

  Future<PaymentModel> createBankTransferPayment(
    String bookingId,
    String proofUrl,
    String reference,
  ) async {
    throw Failures(
      message: 'Manual bank transfer verification is coming soon.',
    );
  }

  Future<PaymentModel> verfiyBankTransferPayment(
    String paymentId,
    bool isVerified,
  ) async {
    throw Failures(
      message: 'Manual bank transfer verification is coming soon.',
    );
  }

  Future<PaymentModel> calculateRefund(String paymentId) async {
    final response = await invokeFunction(
      'calculate-refund-payment',
      body: <String, dynamic>{'payment_id': paymentId},
    );

    return _mapFunctionPaymentResponse(response);
  }

  Future<PaymentModel> processRefundCardPayment(String paymentId) async {
    final response = await invokeFunction(
      'process-refund-payment',
      body: <String, dynamic>{'payment_id': paymentId},
    );

    return _mapFunctionPaymentResponse(response);
  }

  Future<PaymentModel> calculateRescheduleCost(
    String bookingId,
    String newServiceId,
  ) async {
    throw Failures(
      message:
          'Reschedule payment adjustments need finalized pricing rules before '
          'they can be safely automated.',
    );
  }

  Future<PaymentModel> processReschedulePayment(
    String bookingId,
    DateTime newDateTime,
    String newServiceId,
  ) async {
    throw Failures(
      message:
          'Reschedule payment adjustments need finalized pricing rules before '
          'they can be safely automated.',
    );
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
        'payment_intent_client_secret': response['payment_intent_client_secret'],
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
