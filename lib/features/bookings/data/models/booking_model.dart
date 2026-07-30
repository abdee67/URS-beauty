import 'package:urs_beauty/core/constants/app_strings.dart';
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
    super.startedAt,
    super.completedAt,
    super.paymentDueAt,
    super.cashReceivedAt,
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
    required super.commissionAmount,
    required super.stylistEarning,
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
      scheduledAt: AppStrings.asLocalDateTime(json['scheduled_at']),
      endAt: AppStrings.asLocalDateTime(json['end_at']),
      startedAt: AppStrings.asNullableLocalDateTime(json['started_at']),
      completedAt: AppStrings.asNullableLocalDateTime(json['completed_at']),
      paymentDueAt: AppStrings.asNullableLocalDateTime(json['payment_due_at']),
      cashReceivedAt: AppStrings.asNullableLocalDateTime(
        json['cash_received_at'],
      ),
      createdAt: AppStrings.asLocalDateTime(json['created_at']),
      updatedAt: AppStrings.asLocalDateTime(json['updated_at']),
      isReviewed: AppStrings.isReviewedFromString(json['is_reviewed']),
      rescheduledFrom: AppStrings.nullableString(json['rescheduled_from']),
      rescheduledCount: AppStrings.asInt(json['rescheduled_count']),
      paymentMethod: json['payment_method']?.toString() ?? '',
      paymentStatus: _paymentStatusFromString(
        json['payment_status']?.toString() ?? '',
      ),
      currency: json['currency']?.toString() ?? 'ETB',
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      refundAmount: (json['refund_amount'] as num?)?.toDouble() ?? 0.0,
      commissionAmount: (json['commission_amount'] as num?)?.toDouble() ?? 0.0,
      stylistEarning: (json['stylist_earning'] as num?)?.toDouble() ?? 0.0,
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
      startedAt: startedAt,
      completedAt: completedAt,
      paymentDueAt: paymentDueAt,
      cashReceivedAt: cashReceivedAt,
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
      commissionAmount: commissionAmount,
      stylistEarning: stylistEarning,
    );
  }
   Map<String, dynamic> updateBookingPayload(BookingModel booking) {
    return <String, dynamic>{
      'customer': booking.customerId,
      'stylist': booking.stylistId,
      'status': booking.status.name,
      'notes': booking.notes,
      'address': booking.addressId,
      'total_amount': booking.totalAmount,
      'scheduled_at': booking.scheduledAt.toUtc().toIso8601String(),
      'end_at': booking.endAt.toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
      'is_reviewed': booking.isReviewed,
      'rescheduled_from': booking.rescheduledFrom,
      'rescheduled_count': booking.rescheduledCount,
      'payment_method': booking.paymentMethod,
      'payment_status': booking.paymentStatus.name,
      'currency': booking.currency,
      'paid_amount': booking.paidAmount,
      'refund_amount': booking.refundAmount,
      'commission_amount': booking.commissionAmount,
      'stylist_earning': booking.stylistEarning,
    };
  }
   Map<String, dynamic> createBookingPayload(BookingModel booking) {
    final payload = <String, dynamic>{
      'customer': booking.customerId,
      'stylist': booking.stylistId,
      'status': booking.status.name,
      'notes': booking.notes,
      'address': booking.addressId,
      'total_amount': booking.totalAmount,
      'scheduled_at': booking.scheduledAt.toUtc().toIso8601String(),
      'end_at': booking.endAt.toUtc().toIso8601String(),
      'is_reviewed': booking.isReviewed,
      'rescheduled_from': booking.rescheduledFrom,
      'rescheduled_count': booking.rescheduledCount,
      'payment_method': booking.paymentMethod,
      'payment_status': booking.paymentStatus.name,
      'currency': booking.currency,
      'paid_amount': booking.paidAmount,
      'refund_amount': booking.refundAmount,
      'commission_amount': booking.commissionAmount,
      'stylist_earning': booking.stylistEarning,
    };

    if (booking.id.trim().isNotEmpty) {
      payload['id'] = booking.id;
    }

    return payload;
  }

  static BookingStatus _bookingStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'in_progress':
        return BookingStatus.inProgress;
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
      case 'disputed':
        return PaymentStatus.disputed;
      default:
        return PaymentStatus.pending;
    }
  }
}
