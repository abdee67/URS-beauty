class CreateBookingServiceItemModel {
  const CreateBookingServiceItemModel({
    required this.serviceId,
    required this.stylistServiceId,
    required this.quantity,
  });

  final int serviceId;
  final int stylistServiceId;
  final int quantity;

  Map<String, dynamic> toRpcJson() {
    return <String, dynamic>{
      'service_id': serviceId,
      'stylist_service_id': stylistServiceId,
      'quantity': quantity,
    };
  }
}
