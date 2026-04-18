import 'package:urs_beauty/features/payments/domain/entity/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  PaymentModel({
    required super.id,
    required super.bookingId,
    required super.customerId,
    required super.paymentMethod,
    required super.paymentType,
    required super.status,
    required super.amount,
    required super.currency,
    super.transactionReference,
    super.paymentProofUrl,
    super.metaData = const {},
    required super.createdAt,
    required super.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: (_asString(json['id']) ?? '').toString(),
      bookingId: (_asString(json['booking_id']) ?? '').toString(),
      customerId: (_asString(json['customer_id']) ?? '').toString(),
      paymentMethod: _mapPaymentMethod(
        (json['payment_method'])?.toString() ?? '',
      ),
      paymentType: _mapPaymentType((json['payment_type'])?.toString() ?? ''),
      status: _mapPaymentStatus((json['status'])?.toString() ?? ''),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? '',
      transactionReference: _nullableString(json['transaction_reference']),
      paymentProofUrl: _nullableString(json['payment_proof_url']),
      metaData: json['meta_data'] is Map<String, dynamic>
          ? json['meta_data'] as Map<String, dynamic>
          : const {},
      createdAt: _asLocalDateTime(json['created_at']),
      updatedAt: _asLocalDateTime(json['updated_at']),
    );
  }
  static PaymentModel toEntity(PaymentModel model) {
    return PaymentModel(
      id: model.id,
      bookingId: model.bookingId,
      customerId: model.customerId,
      paymentMethod: model.paymentMethod,
      paymentType: model.paymentType,
      status: model.status,
      amount: model.amount,
      currency: model.currency,
      transactionReference: model.transactionReference,
      paymentProofUrl: model.paymentProofUrl,
      metaData: model.metaData,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static DateTime _asLocalDateTime(dynamic value) {
    final parsed = DateTime.parse(value.toString());
    return parsed.isUtc ? parsed.toLocal() : parsed;
  }

  static String? _asString(dynamic value) {
    return value?.toString();
  }

  static String? _nullableString(dynamic value) {
    final normalized = value?.toString().trim() ?? '';
    if (normalized.isEmpty || normalized.toLowerCase() == 'null') {
      return null;
    }
    return normalized;
  }

  static PaymentMethod _mapPaymentMethod(String value) {
    switch (value) {
      case 'card':
        return PaymentMethod.card;
      case 'bankTransfer':
        return PaymentMethod.bankTransfer;
      default:
        return PaymentMethod.card;
    }
  }

  static PaymentType _mapPaymentType(String value) {
    switch (value) {
      case 'payment':
        return PaymentType.payment;
      case 'adjustment':
        return PaymentType.adjustment;
      case 'refund':
        return PaymentType.refund;
      default:
        return PaymentType.payment;
    }
  }

  static PaymentStatus _mapPaymentStatus(String value) {
    switch (value) {
      case 'pending':
        return PaymentStatus.pending;
      case 'success':
        return PaymentStatus.success;
      case 'failed':
        return PaymentStatus.failed;
      default:
        return PaymentStatus.pending;
    }
  }
}
