import 'package:urs_beauty/features/bookings/data/models/create_booking_service_item_model.dart';

class CreateBookingRequestModel {
  const CreateBookingRequestModel({
    required this.customerId,
    required this.stylistId,
    required this.scheduledAt,
    required this.address,
    required this.items,
    this.notes,
  });

  final String customerId;
  final String stylistId;
  final DateTime scheduledAt;
  final String address;
  final String? notes;
  final List<CreateBookingServiceItemModel> items;

  Map<String, dynamic> toRpcParams() {
    final normalizedNotes = notes?.trim();

    return <String, dynamic>{
      'p_customer_id': customerId,
      'p_stylist_id': stylistId,
      'p_scheduled_at': scheduledAt.toIso8601String(),
      'p_address': address.trim(),
      'p_notes': normalizedNotes == null || normalizedNotes.isEmpty
          ? null
          : normalizedNotes,
      'p_items': items.map((item) => item.toRpcJson()).toList(),
    };
  }
}
