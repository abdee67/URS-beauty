class RescheduleBookingRequestEntity {
  const RescheduleBookingRequestEntity({
    required this.bookingId,
    required this.stylistId,
    required this.scheduledAt,
  });

  final String bookingId;
  final String stylistId;
  final DateTime scheduledAt;
}
