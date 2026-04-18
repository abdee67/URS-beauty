import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  BookingModel({
    required super.id,
    required super.customerId,
    required super.stylistId,
    super.serviceName,
    super.stylistName,
    required super.status,
    super.notes,
    required super.addressId,
    required super.totalAmount,
    required super.scheduledAt,
    required super.endAt,
    required super.createdAt,
    required super.updatedAt,
    required super.isReviewed,
    super.rescheduledFrom,
    required super.rescheduledCount,
    required super.paymentMethod,
    required super.paymentStatus,
    required super.currency,
    required super.paidAmount,
    required super.refundAmount,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final stylistProfile = json['stylist_profile'];
    final bookedServices = json['booked_services'];
    final resolvedServiceName =
        bookedServices is List && bookedServices.isNotEmpty
        ? (Map<String, dynamic>.from(
                    bookedServices.first as Map,
                  )['service_name'] ??
                  '')
              .toString()
        : '';
    final resolvedStylistName = stylistProfile is Map
        ? (Map<String, dynamic>.from(stylistProfile)['business_name'] ?? '')
              .toString()
        : '';

    return BookingModel(
      id: (json['id'] ?? '').toString(),
      customerId: (json['customer'] ?? '').toString(),
      stylistId: (json['stylist'] ?? '').toString(),
      serviceName: resolvedServiceName,
      stylistName: resolvedStylistName,
      status: _bookingStatusFromString(
        (json['status'] ?? 'pending').toString(),
      ),
      notes: json['notes']?.toString(),
      addressId: (json['address'] ?? '').toString(),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      scheduledAt: _asLocalDateTime(json['scheduled_at']),
      endAt: _asLocalDateTime(json['end_at']),
      createdAt: _asLocalDateTime(json['created_at']),
      updatedAt: _asLocalDateTime(json['updated_at']),
      isReviewed: _isReviewedFromString(json['is_reviewed']),
      rescheduledFrom: _nullableString(json['rescheduled_from']),
      rescheduledCount: _asInt(json['rescheduled_count']),
      paymentMethod: json['payment_method']?.toString() ?? '',
      paymentStatus: _paymentStatusFromString(
        json['payment_status']?.toString() ?? '',
      ),
      currency: json['currency']?.toString() ?? 'ETB',
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      refundAmount: (json['refund_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  BookingModel toEntity() {
    return BookingModel(
      id: id,
      customerId: customerId,
      stylistId: stylistId,
      serviceName: serviceName,
      stylistName: stylistName,
      status: status,
      notes: notes,
      addressId: addressId,
      totalAmount: totalAmount,
      scheduledAt: scheduledAt,
      endAt: endAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isReviewed: isReviewed,
      rescheduledFrom: rescheduledFrom,
      rescheduledCount: rescheduledCount,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      currency: currency,
      paidAmount: paidAmount,
      refundAmount: refundAmount,
    );
  }

  static BookingStatus _bookingStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'no_show':
        return BookingStatus.noShow;
      default:
        return BookingStatus.pending;
    }
  }

  static PaymentStatus _paymentStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'paid':
        return PaymentStatus.paid;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'failed':
        return PaymentStatus.failed;
      case 'partial_refunded':
        return PaymentStatus.partialRefunded;
      case 'pending_verification':
        return PaymentStatus.pendingVerification;
      default:
        return PaymentStatus.pending;
    }
  }

  static DateTime _asLocalDateTime(dynamic value) {
    final parsed = DateTime.parse(value.toString());
    return parsed.isUtc ? parsed.toLocal() : parsed;
  }

  static bool _isReviewedFromString(dynamic value) {
    return value.toString().toLowerCase() == 'true';
  }

  static String? _nullableString(dynamic value) {
    final normalized = value?.toString().trim() ?? '';
    if (normalized.isEmpty || normalized.toLowerCase() == 'null') {
      return null;
    }
    return normalized;
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String && value.trim().isNotEmpty) {
      return int.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }
}
