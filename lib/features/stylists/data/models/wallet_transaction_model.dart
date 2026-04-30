import 'package:urs_beauty/core/constants/app_strings.dart';
import 'package:urs_beauty/features/stylists/domain/entities/wallet_transaction_entity.dart';

class WalletTransactionModel extends WalletTransactionEntity {
  WalletTransactionModel({
    required super.id,
    required super.walletId,
    required super.bookingId,
    required super.transactionType,
    required super.amount,
    required super.source,
    required super.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: AppStrings.asString(json['id']),
      walletId: AppStrings.asString(json['wallet_id']),
      bookingId: AppStrings.asString(json['booking_id']),
      transactionType: _transactionTypeFromString(json['transaction_type']),
      amount: AppStrings.asDouble(json['amount']),
      source: _sourceFromString(json['source']),
      createdAt: AppStrings.asLocalDateTime(json['created_at']),
    );
  }

  WalletTransactionEntity toEntity() {
    return WalletTransactionEntity(
      id: id,
      walletId: walletId,
      bookingId: bookingId,
      transactionType: transactionType,
      amount: amount,
      source: source,
      createdAt: createdAt,
    );
  }

  static TransactionType _transactionTypeFromString(String value) {
    switch (value.toLowerCase()) {
      case 'credit':
        return TransactionType.credit;
      case 'debit':
        return TransactionType.debit;
      default:
        return TransactionType.debit;
    }
  }

  static Source _sourceFromString(String value) {
    switch (value.toLowerCase()) {
      case 'booking_earning':
        return Source.bookingEarning;
      case 'commission':
        return Source.commission;
      case 'penalty':
        return Source.penalty;
      case 'withdrawal':
        return Source.withdrawal;
      case 'topup':
        return Source.topup;
      default:
        return Source.topup;
    }
  }
}
