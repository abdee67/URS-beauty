import 'package:urs_beauty/features/bookings/domain/entities/create_booking_service_item.dart';

class CreateBookingRequestEntity {
  const CreateBookingRequestEntity({
    required this.customerId,
    required this.stylistId,
    required this.scheduledAt,
    required this.addressId,
    required this.items,
    this.notes,
  });

  final String customerId;
  final String stylistId;
  final DateTime scheduledAt;
  final String addressId;
  final String? notes;
  final List<CreateBookingServiceItemEntity> items;
}
