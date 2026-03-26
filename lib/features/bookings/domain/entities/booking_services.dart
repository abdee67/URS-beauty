class BookingServicesEntity {
  final String id;
  final String bookingId;
  final String serviceName;
  final int serviceId;
  final int stylistServiceId;
  final int quantity;
  final double priceAtBooking;
  final int durationAtBooking;

  const BookingServicesEntity({
    required this.id,
    required this.bookingId,
    required this.serviceName,
    required this.serviceId,
    required this.stylistServiceId,
    required this.quantity,
    required this.priceAtBooking,
    required this.durationAtBooking,
  });
}
