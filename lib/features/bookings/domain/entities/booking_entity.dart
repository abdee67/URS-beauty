enum BookingStatus { pending,  completed, cancelled, noShow }

enum PaymentStatus {
  pending,
  paid,
  refunded,
  failed,
  partialRefunded,
  pendingVerification,
}

class BookingEntity {
  final String id;
  final String customerId;
  final String stylistId;
  final String serviceName;
  final String stylistName;
  final BookingStatus status;
  final String? notes;
  final String addressId;
  final double totalAmount;
  final DateTime scheduledAt;
  final DateTime endAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isReviewed;
  final String? rescheduledFrom;
  final int rescheduledCount;
  final String paymentMethod;
  final PaymentStatus paymentStatus;
  final String? currency;
  final double? paidAmount;
  final double? refundAmount;
  final double? commissionAmount;
  final double? stylistEarning;

  bool get isPaid => paymentStatus == PaymentStatus.paid;

  bool get isPaymentAwaitingVerification =>
      paymentStatus == PaymentStatus.pendingVerification;

  bool get canReviewCompletedService =>
      status == BookingStatus.completed && isPaid && !isReviewed;

  bool get canCollectPostServicePayment =>
      status == BookingStatus.completed &&
      (paymentStatus == PaymentStatus.pending ||
          paymentStatus == PaymentStatus.failed);

  const BookingEntity({
    required this.id,
    required this.customerId,
    required this.stylistId,
    this.serviceName = '',
    this.stylistName = '',
    required this.status,
    this.notes,
    required this.addressId,
    required this.totalAmount,
    required this.scheduledAt,
    required this.endAt,
    required this.createdAt,
    required this.updatedAt,
    this.isReviewed = false,
    this.rescheduledFrom,
    this.rescheduledCount = 0,
    this.paymentMethod = '',
    this.paymentStatus = PaymentStatus.pending,
    this.currency = 'ETB',
    this.paidAmount = 0,
    this.refundAmount = 0,
    this.commissionAmount = 0,
    this.stylistEarning = 0,
  });
}
