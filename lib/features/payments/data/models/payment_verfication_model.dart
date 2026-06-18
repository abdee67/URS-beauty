import 'package:urs_beauty/features/payments/domain/entity/payment_verification.dart';

class PaymentVerificationModel extends PaymentVerificationEntity {
  PaymentVerificationModel({
    required super.id,
    required super.bookingId,
    required super.paymentId,
    required super.status,
    required super.verifiedBy,
    required super.note,
    required super.createdAt,
    required super.verifiedAt,
  });

  factory PaymentVerificationModel.fromJson(Map<String, dynamic> json) {
    return PaymentVerificationModel(
      id: json['id'].toString(),
      bookingId: json['booking_id'].toString(),
      paymentId: json['payment_id'].toString(),
      status: _statusFromString(json['status'].toString()),
      verifiedBy: json['verified_by']?.toString(),
      note: json['note']?.toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
      verifiedAt: DateTime.parse(json['verified_at'].toString()),
    );
  }

  static PaymentVerificationStatus _statusFromString(String status) {
    switch (status) {
      case 'verified':
        return PaymentVerificationStatus.verified;
      case 'rejected':
        return PaymentVerificationStatus.rejected;
      default:
        throw Exception('Invalid payment verification status: $status');
    }
  }

  PaymentVerificationEntity toEntity() {
    return PaymentVerificationEntity(
      id: id,
      bookingId: bookingId,
      paymentId: paymentId,
      status: status,
      verifiedBy: verifiedBy,
      note: note,
      createdAt: createdAt,
      verifiedAt: verifiedAt,
    );
  }
}
