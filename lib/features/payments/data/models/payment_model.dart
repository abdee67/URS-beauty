import 'package:urs_beauty/features/payments/domain/entity/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
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
    super.idempotencyKey,
    super.stripePaymentIntentId,
    super.stripeCheckoutSessionId,
    super.paymentIntentClientSecret,
    super.failureReason,
    super.refundableAmount = 0,
    super.refundedAmount = 0,
    super.adjustmentAmount = 0,
    super.bookingStatus,
    super.bookingPaymentStatus,
    super.paidAt,
    super.verifiedAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    final metadata = _metadataFromJson(json);
    final refundPercentage = json['refund_percentage'];
    if (refundPercentage != null) {
      metadata['refund_percentage'] = refundPercentage;
    }

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
      currency: (json['currency']?.toString() ?? 'ETB').toUpperCase(),
      transactionReference: _nullableString(json['transaction_reference']),
      paymentProofUrl: _nullableString(json['payment_proof_url']),
      metaData: Map<String, dynamic>.unmodifiable(metadata),
      idempotencyKey: _nullableString(json['idempotency_key']),
      stripePaymentIntentId: _nullableString(json['stripe_payment_intent_id']),
      stripeCheckoutSessionId: _nullableString(
        json['stripe_checkout_session_id'],
      ),
      paymentIntentClientSecret:
          _nullableString(json['payment_intent_client_secret']) ??
          _nullableString(json['client_secret']),
      failureReason: _nullableString(json['failure_reason']),
      refundableAmount: (json['refundable_amount'] as num?)?.toDouble() ?? 0.0,
      refundedAmount: (json['refunded_amount'] as num?)?.toDouble() ?? 0.0,
      adjustmentAmount: (json['adjustment_amount'] as num?)?.toDouble() ?? 0.0,
      bookingStatus: _nullableString(json['booking_status']),
      bookingPaymentStatus: _nullableString(json['booking_payment_status']),
      paidAt: _asNullableDateTime(json['paid_at']),
      verifiedAt: _asNullableDateTime(json['verified_at']),
      createdAt: _asDateTime(json['created_at']),
      updatedAt: _asDateTime(json['updated_at']),
    );
  }

  factory PaymentModel.fromEntity(PaymentEntity entity) {
    return PaymentModel(
      id: entity.id,
      bookingId: entity.bookingId,
      customerId: entity.customerId,
      paymentMethod: entity.paymentMethod,
      paymentType: entity.paymentType,
      status: entity.status,
      amount: entity.amount,
      currency: entity.currency,
      transactionReference: entity.transactionReference,
      paymentProofUrl: entity.paymentProofUrl,
      metaData: entity.metaData,
      idempotencyKey: entity.idempotencyKey,
      stripePaymentIntentId: entity.stripePaymentIntentId,
      stripeCheckoutSessionId: entity.stripeCheckoutSessionId,
      paymentIntentClientSecret: entity.paymentIntentClientSecret,
      failureReason: entity.failureReason,
      refundableAmount: entity.refundableAmount,
      refundedAmount: entity.refundedAmount,
      adjustmentAmount: entity.adjustmentAmount,
      bookingStatus: entity.bookingStatus,
      bookingPaymentStatus: entity.bookingPaymentStatus,
      paidAt: entity.paidAt,
      verifiedAt: entity.verifiedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  PaymentEntity toEntity() {
    return PaymentEntity(
      id: id,
      bookingId: bookingId,
      customerId: customerId,
      paymentMethod: paymentMethod,
      paymentType: paymentType,
      status: status,
      amount: amount,
      currency: currency,
      transactionReference: transactionReference,
      paymentProofUrl: paymentProofUrl,
      metaData: metaData,
      idempotencyKey: idempotencyKey,
      stripePaymentIntentId: stripePaymentIntentId,
      stripeCheckoutSessionId: stripeCheckoutSessionId,
      paymentIntentClientSecret: paymentIntentClientSecret,
      failureReason: failureReason,
      refundableAmount: refundableAmount,
      refundedAmount: refundedAmount,
      adjustmentAmount: adjustmentAmount,
      bookingStatus: bookingStatus,
      bookingPaymentStatus: bookingPaymentStatus,
      paidAt: paidAt,
      verifiedAt: verifiedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'booking_id': bookingId,
      'customer_id': customerId,
      'payment_method': paymentMethod.apiValue,
      'payment_type': paymentType.apiValue,
      'status': status.apiValue,
      'amount': amount,
      'currency': currency.toLowerCase(),
      'transaction_reference': transactionReference,
      'payment_proof_url': paymentProofUrl,
      'metadata': metaData,
      'idempotency_key': idempotencyKey,
      'stripe_payment_intent_id': stripePaymentIntentId,
      'stripe_checkout_session_id': stripeCheckoutSessionId,
      'payment_intent_client_secret': paymentIntentClientSecret,
      'failure_reason': failureReason,
      'refundable_amount': refundableAmount,
      'refunded_amount': refundedAmount,
      'adjustment_amount': adjustmentAmount,
      'booking_status': bookingStatus,
      'booking_payment_status': bookingPaymentStatus,
      'paid_at': paidAt?.toUtc().toIso8601String(),
      'verified_at': verifiedAt?.toUtc().toIso8601String(),
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }

  static DateTime _asDateTime(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }

    final parsed = DateTime.parse(value.toString());
    return parsed.isUtc ? parsed.toLocal() : parsed;
  }

  static DateTime? _asNullableDateTime(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return null;
    }

    return _asDateTime(value);
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

  static Map<String, dynamic> _metadataFromJson(Map<String, dynamic> json) {
    if (json['meta_data'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(json['meta_data'] as Map<String, dynamic>);
    }

    if (json['meta_data'] is Map) {
      return Map<String, dynamic>.from(json['meta_data'] as Map);
    }

    if (json['metadata'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(json['metadata'] as Map<String, dynamic>);
    }

    if (json['metadata'] is Map) {
      return Map<String, dynamic>.from(json['metadata'] as Map);
    }

    return <String, dynamic>{};
  }

  static PaymentMethod _mapPaymentMethod(String value) {
    switch (value.toLowerCase()) {
      case 'card':
        return PaymentMethod.card;
      case 'bank_transfer':
      case 'banktransfer':
        return PaymentMethod.bankTransfer;
      case 'cash':
        return PaymentMethod.cash;
      default:
        return PaymentMethod.card;
    }
  }

  static PaymentType _mapPaymentType(String value) {
    switch (value.toLowerCase()) {
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
    switch (value.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'processing':
        return PaymentStatus.processing;
      case 'requires_action':
        return PaymentStatus.requiresAction;
      case 'success':
      case 'succeeded':
      case 'paid':
        return PaymentStatus.succeeded;
      case 'cancelled':
      case 'canceled':
        return PaymentStatus.cancelled;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'partially_refunded':
      case 'partial_refunded':
        return PaymentStatus.partiallyRefunded;
      case 'pending_verification':
        return PaymentStatus.pendingVerification;
      case 'failed':
        return PaymentStatus.failed;
      default:
        return PaymentStatus.pending;
    }
  }
}
