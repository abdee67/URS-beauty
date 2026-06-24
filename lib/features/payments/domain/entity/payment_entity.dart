import 'package:equatable/equatable.dart';

enum PaymentStatus {
  pending,
  processing,
  requiresAction,
  succeeded,
  failed,
  cancelled,
  refunded,
  partiallyRefunded,
  pendingVerification,
}

enum PaymentMethod { card, wallet, bankTransfer, cash }

enum PaymentType { payment, adjustment, refund }

extension PaymentStatusX on PaymentStatus {
  String get apiValue {
    switch (this) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.processing:
        return 'processing';
      case PaymentStatus.requiresAction:
        return 'requires_action';
      case PaymentStatus.succeeded:
        return 'succeeded';
      case PaymentStatus.failed:
        return 'failed';
      case PaymentStatus.cancelled:
        return 'cancelled';
      case PaymentStatus.refunded:
        return 'refunded';
      case PaymentStatus.partiallyRefunded:
        return 'partially_refunded';
      case PaymentStatus.pendingVerification:
        return 'pending_verification';
    }
  }

  bool get isTerminal {
    return this == PaymentStatus.succeeded ||
        this == PaymentStatus.failed ||
        this == PaymentStatus.cancelled ||
        this == PaymentStatus.refunded ||
        this == PaymentStatus.partiallyRefunded;
  }
}

extension PaymentMethodX on PaymentMethod {
  String get apiValue {
    switch (this) {
      case PaymentMethod.card:
        return 'card';
      case PaymentMethod.wallet:
        return 'wallet';
      case PaymentMethod.bankTransfer:
        return 'bank_transfer';
      case PaymentMethod.cash:
        return 'cash';
    }
  }

  String get label {
    switch (this) {
      case PaymentMethod.card:
        return 'Card Payment';
      case PaymentMethod.wallet:
        return 'Wallet Payment';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.cash:
        return 'Cash Payment';
    }
  }
}

extension PaymentTypeX on PaymentType {
  String get apiValue {
    switch (this) {
      case PaymentType.payment:
        return 'payment';
      case PaymentType.adjustment:
        return 'adjustment';
      case PaymentType.refund:
        return 'refund';
    }
  }
}

class PaymentEntity extends Equatable {
  const PaymentEntity({
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
    this.idempotencyKey,
    this.stripePaymentIntentId,
    this.stripeCheckoutSessionId,
    this.paymentIntentClientSecret,
    this.failureReason,
    this.refundableAmount = 0,
    this.refundedAmount = 0,
    this.adjustmentAmount = 0,
    this.bookingStatus,
    this.bookingPaymentStatus,
    this.paidAt,
    this.verifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

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
  final String? idempotencyKey;
  final String? stripePaymentIntentId;
  final String? stripeCheckoutSessionId;
  final String? paymentIntentClientSecret;
  final String? failureReason;
  final double refundableAmount;
  final double refundedAmount;
  final double adjustmentAmount;
  final String? bookingStatus;
  final String? bookingPaymentStatus;
  final DateTime? paidAt;
  final DateTime? verifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isSuccessful => status == PaymentStatus.succeeded;

  bool get canRetry =>
      status == PaymentStatus.failed || status == PaymentStatus.cancelled;

  bool get isAwaitingConfirmation =>
      status == PaymentStatus.pending ||
      status == PaymentStatus.processing ||
      status == PaymentStatus.requiresAction ||
      status == PaymentStatus.pendingVerification;

  PaymentEntity copyWith({
    String? id,
    String? bookingId,
    String? customerId,
    PaymentMethod? paymentMethod,
    PaymentType? paymentType,
    PaymentStatus? status,
    double? amount,
    String? currency,
    String? transactionReference,
    String? paymentProofUrl,
    Map<String, dynamic>? metaData,
    String? idempotencyKey,
    String? stripePaymentIntentId,
    String? stripeCheckoutSessionId,
    String? paymentIntentClientSecret,
    String? failureReason,
    double? refundableAmount,
    double? refundedAmount,
    double? adjustmentAmount,
    String? bookingStatus,
    String? bookingPaymentStatus,
    DateTime? paidAt,
    DateTime? verifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentEntity(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      customerId: customerId ?? this.customerId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentType: paymentType ?? this.paymentType,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      transactionReference: transactionReference ?? this.transactionReference,
      paymentProofUrl: paymentProofUrl ?? this.paymentProofUrl,
      metaData: metaData ?? this.metaData,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      stripePaymentIntentId:
          stripePaymentIntentId ?? this.stripePaymentIntentId,
      stripeCheckoutSessionId:
          stripeCheckoutSessionId ?? this.stripeCheckoutSessionId,
      paymentIntentClientSecret:
          paymentIntentClientSecret ?? this.paymentIntentClientSecret,
      failureReason: failureReason ?? this.failureReason,
      refundableAmount: refundableAmount ?? this.refundableAmount,
      refundedAmount: refundedAmount ?? this.refundedAmount,
      adjustmentAmount: adjustmentAmount ?? this.adjustmentAmount,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      bookingPaymentStatus: bookingPaymentStatus ?? this.bookingPaymentStatus,
      paidAt: paidAt ?? this.paidAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    bookingId,
    customerId,
    paymentMethod,
    paymentType,
    status,
    amount,
    currency,
    transactionReference,
    paymentProofUrl,
    metaData,
    idempotencyKey,
    stripePaymentIntentId,
    stripeCheckoutSessionId,
    paymentIntentClientSecret,
    failureReason,
    refundableAmount,
    refundedAmount,
    adjustmentAmount,
    bookingStatus,
    bookingPaymentStatus,
    paidAt,
    verifiedAt,
    createdAt,
    updatedAt,
  ];
}
