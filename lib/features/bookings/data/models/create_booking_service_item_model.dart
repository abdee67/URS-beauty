import 'package:urs_beauty/features/bookings/domain/entities/create_booking_service_item.dart';

class CreateBookingServiceItemModel extends CreateBookingServiceItemEntity {
  const CreateBookingServiceItemModel({
    required super.serviceId,
    required super.stylistServiceId,
    required super.quantity,
  });

  Map<String, dynamic> toRpcJson() {
    return <String, dynamic>{
      'service_id': serviceId,
      'stylist_service_id': stylistServiceId,
      'quantity': quantity,
    };
  }
}
