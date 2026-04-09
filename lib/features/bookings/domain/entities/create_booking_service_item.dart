class CreateBookingServiceItemEntity {
  const CreateBookingServiceItemEntity({
    required this.serviceId,
    required this.stylistServiceId,
    required this.quantity,
  });

  final String serviceId;
  final String stylistServiceId;
  final int quantity;
}
