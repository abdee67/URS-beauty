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
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final stylistProfile = json['stylist_profile'];
    final bookedServices = json['booked_services'];
    final resolvedServiceName = bookedServices is List && bookedServices.isNotEmpty
        ? (Map<String, dynamic>.from(bookedServices.first as Map)['service_name'] ??
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
      status: _bookingStatusFromString((json['status'] ?? 'pending').toString()),
      notes: json['notes']?.toString(),
      addressId: (json['address'] ?? '').toString(),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      scheduledAt: DateTime.parse(json['scheduled_at'].toString()),
      endAt: DateTime.parse(json['end_at'].toString()),
      createdAt: DateTime.parse(json['created_at'].toString()),
      updatedAt: DateTime.parse(json['updated_at'].toString()),
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
    );
  }

  static BookingStatus _bookingStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }
}
