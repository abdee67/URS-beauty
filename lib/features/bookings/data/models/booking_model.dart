import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  BookingModel({
    required super.id,
    required super. customerId,
    required super. stylistId,
    required super. status,
     super. notes,
    required super. address,
    required super. totalAmount,
    required super. scheduledAt,
    required super. endAt,
    required super. createdAt,
    required super. updatedAt,
  }) ;

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      customerId: json['customer'] ?? '',
      stylistId: json['stylist'] ?? '',
      status: _bookingStatusFromString(json['status'] ?? 'pending'),
      notes: json['notes'],
      address: json['address'] ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      scheduledAt: DateTime.parse(json['scheduled_at']),
      endAt: DateTime.parse(json['end_at']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
BookingModel toEntity() {
    return BookingModel(
      id: id,
      customerId: customerId,
      stylistId: stylistId,
      status: status,
      notes: notes,
      address: address,
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
        return BookingStatus.pending; // Default to pending if unknown
    }
  }
}