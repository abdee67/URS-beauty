import 'package:urs_beauty/core/constants/app_strings.dart';
import 'package:urs_beauty/features/stylists/domain/entities/payouts_entity.dart';

class PayoutModel extends PayoutsEntity {
  PayoutModel({
    required super.id,
    required super.walletId,
    required super.status,
    required super.amount,
    required super.payoutMethod,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PayoutModel.fromJson(Map<String, dynamic> json) {
    return PayoutModel(
      id: AppStrings.asString(json['id']),
      walletId: AppStrings.asString(json['wallet_id']),
      status: _statusFromString(json['status']),
      amount: AppStrings.asDouble(json['amount']),
      payoutMethod: _payoutMethodFromString(json['payout_method']),
      createdAt: AppStrings.asLocalDateTime(json['created_at']),
      updatedAt: AppStrings.asLocalDateTime(json['updated_at']),
    );
  }

  PayoutsEntity toEntity() {
    return PayoutsEntity(
      id: id,
      walletId: walletId,
      status: status,
      amount: amount,
      payoutMethod: payoutMethod,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static PayoutStatus _statusFromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return PayoutStatus.pending;
      case 'processing':
        return PayoutStatus.processing;
      case 'paid':
        return PayoutStatus.paid;
      case 'cancelled':
        return PayoutStatus.cancelled;
      default:
        return PayoutStatus.pending;
    }
  }

  static PayoutMethod _payoutMethodFromString(String value) {
    switch (value.toLowerCase()) {
      case 'bank_transfer':
        return PayoutMethod.bankTransfer;
      case 'paypal':
        return PayoutMethod.payPal;
      case 'stripe':
        return PayoutMethod.stripe;
      default:
        return PayoutMethod.bankTransfer;
    }
  }
}
