enum PaymentStatus {
  pending,
  success,
  failed,
}

enum PaymentMethod {
  card,
  bankTransfer,
}

enum PaymentType {
  payment,
  adjustment,
  refund,
}

class PaymentEntity {
  final String id;
  final String bookingId;
  final String customerId;
  final PaymentMethod paymentMethod;
  final PaymentType paymentType;
  final PaymentStatus status;
  final double amount;
  final String currency;
  final String? transactionReference;
  final String? paymentProofUrl;
  final Map<String, dynamic> metaData;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentEntity({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.paymentMethod,
    required this.paymentType,
    required this.status,
    required this.amount,
    required this.currency,
    this.transactionReference,
    this.paymentProofUrl,
    this.metaData = const {},
    required this.createdAt,
    required this.updatedAt,
  });
}
