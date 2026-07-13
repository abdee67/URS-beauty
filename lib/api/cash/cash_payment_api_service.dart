import 'package:urs_beauty/api/api_service.dart';
import 'package:urs_beauty/core/errors/error_handler.dart';
import 'package:urs_beauty/features/payments/data/models/payment_model.dart';

class CashPaymentApiService extends ApiService {
  CashPaymentApiService({super.client});

  Future<PaymentModel> receiveCashPayment(String bookingId) {
    return serviceError(() async {
      requireValue(bookingId, 'Booking id is required');

      final response = await invokeFunction(
        'receive-cash-payment',
        body: {'booking_id': bookingId},
      );
      return _mapResponse(response, fallbackBookingId: bookingId);
    });
  }

  Future<PaymentModel> customerConfirmCashPayment(
    String customerId,
    String bookingId,
  ) {
    return serviceError(() async {
      requireValue(bookingId, 'Booking id is required');
      requireValue(customerId, 'Customer id is required');

      final response = await invokeFunction(
        'confirm-cash-payment',
        body: {'booking_id': bookingId, 'customer_id': customerId},
      );
      return _mapResponse(response, fallbackBookingId: bookingId);
    });
  }

  Future<PaymentModel> customerDisputeCashPayment(
    String customerId,
    String bookingId,
    String? note,
  ) {
    return serviceError(() async {
      requireValue(bookingId, 'Booking id is required');
      requireValue(customerId, 'Customer id is required');

      final response = await invokeFunction(
        'dispute-cash-payment',
        body: {
          'booking_id': bookingId,
          'customer_id': customerId,
          if (note != null) 'note': note,
        },
      );
      return _mapResponse(response, fallbackBookingId: bookingId);
    });
  }

  // Follow the same pattern as StripeApiService._mapFunctionPaymentResponse
  PaymentModel _mapResponse(
    Map<String, dynamic> response, {
    String? fallbackBookingId,
  }) {
    final payload = response['payment'] is Map
        ? requireMap(response['payment'], context: 'payment')
        : response;

    final merged = <String, dynamic>{
      ...payload,
      if (fallbackBookingId != null &&
          (payload['booking_id']?.toString().trim().isEmpty ?? true))
        'booking_id': fallbackBookingId,
      if (response['booking_status'] != null)
        'booking_status': response['booking_status'],
      if (response['booking_payment_status'] != null)
        'booking_payment_status': response['booking_payment_status'],
    };

    return PaymentModel.fromJson(merged);
  }
}
