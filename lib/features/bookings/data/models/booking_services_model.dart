import 'package:urs_beauty/features/bookings/domain/entities/booking_services.dart';

class BookingServicesModel extends BookingServicesEntity {
  const BookingServicesModel({
    required super.id,
    required super.bookingId,
    required super.serviceName,
    required super.serviceId,
    required super.stylistServiceId,
    required super.quantity,
    required super.priceAtBooking,
    required super.durationAtBooking,
  });

  factory BookingServicesModel.fromJson(Map<String, dynamic> json) {
    return BookingServicesModel(
      id: (json['id'] ?? '').toString(),
      bookingId: (json['booking_id'] ?? json['booking'] ?? '').toString(),
      serviceName: (json['service_name'] ?? '').toString(),
      serviceId: _asInt(json['service_id'] ?? json['service']),
      stylistServiceId: _asInt(
        json['stylist_service_id'] ?? json['stylist_service'],
      ),
      quantity: _asInt(json['quantity']),
      priceAtBooking: (json['price_at_booking'] as num?)?.toDouble() ?? 0.0,
      durationAtBooking: _asInt(json['duration_at_booking']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'booking_id': bookingId,
      'service_name': serviceName,
      'service_id': serviceId,
      'stylist_service_id': stylistServiceId,
      'quantity': quantity,
      'price_at_booking': priceAtBooking,
      'duration_at_booking': durationAtBooking,
    };
  }

  Map<String, dynamic> toInsertJson(String bookingId) {
    return <String, dynamic>{
      'booking_id': bookingId,
      'service_name': serviceName,
      'service_id': serviceId,
      'stylist_service_id': stylistServiceId,
      'quantity': quantity,
      'price_at_booking': priceAtBooking,
      'duration_at_booking': durationAtBooking,
    };
  }

  BookingServicesModel toEntity() {
    return BookingServicesModel(
      id: id,
      bookingId: bookingId,
      serviceName: serviceName,
      serviceId: serviceId,
      stylistServiceId: stylistServiceId,
      quantity: quantity,
      priceAtBooking: priceAtBooking,
      durationAtBooking: durationAtBooking,
    );
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
