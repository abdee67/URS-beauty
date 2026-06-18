enum PaymentVerificationStatus { verified, rejected }

class PaymentVerificationEntity {
  final String id;
  final String paymentId;
  final String bookingId;
  final PaymentVerificationStatus status;
  final String? verifiedBy;
  final String? note;
  final DateTime createdAt;
  final DateTime verifiedAt;

  PaymentVerificationEntity({
    required this.id,
    required this.bookingId,
    required this.paymentId,
    required this.status,
    required this.verifiedBy,
    required this.note,
    required this.createdAt,
    required this.verifiedAt,
  });
}
