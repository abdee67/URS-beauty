enum BookingStatus{
  pending,
  confirmed,
  completed,
  cancelled,
}

class BookingEntity {
  final String id;
  final String customerId;
  final String stylistId;
  final BookingStatus status;
  final String? notes;
  final String address;
  final double totalAmount;
  final DateTime scheduledAt;
  final DateTime endAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookingEntity({
    required this.id,
    required this.customerId,
    required this.stylistId,
    required this.status,
     this.notes,
    required this.address,
    required this.totalAmount,
    required this.scheduledAt,
    required this.endAt,
    required this.createdAt,
    required this.updatedAt,
  });
}