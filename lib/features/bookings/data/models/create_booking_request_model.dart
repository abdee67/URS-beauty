import 'package:urs_beauty/features/bookings/domain/entities/create_booking_request.dart';
import 'package:urs_beauty/features/bookings/data/models/create_booking_service_item_model.dart';

class CreateBookingRequestModel extends CreateBookingRequestEntity {
  const CreateBookingRequestModel({
    required super.customerId,
    required super.stylistId,
    required super.scheduledAt,
    required super.addressId,
    required List<CreateBookingServiceItemModel> super.items,
    super.notes,
  });

  Map<String, dynamic> toRpcParams() {
    final normalizedNotes = notes?.trim();

    return <String, dynamic>{
      'p_customer_id': customerId,
      'p_stylist_id': stylistId,
      'p_scheduled_at': scheduledAt.toIso8601String(),
      'p_address_id': addressId,
      'p_notes': normalizedNotes == null || normalizedNotes.isEmpty
          ? null
          : normalizedNotes,
      'p_items': items
          .map(
            (item) => CreateBookingServiceItemModel(
              serviceId: item.serviceId,
              stylistServiceId: item.stylistServiceId,
              quantity: item.quantity,
            ).toRpcJson(),
          )
          .toList(),
    };
  }
}
