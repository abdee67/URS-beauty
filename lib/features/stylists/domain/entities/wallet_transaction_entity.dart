enum TransactionType { credit, debit }

enum Source { bookingEarning, commission, penalty, withdrawal, topup }

class WalletTransactionEntity {
  final String id;
  final String walletId;
  final String bookingId;
  final TransactionType transactionType;
  final double amount;
  final Source source;
  final DateTime createdAt;

  WalletTransactionEntity({
    required this.id,
    required this.walletId,
    required this.bookingId,
    required this.transactionType,
    required this.amount,
    required this.source,
    required this.createdAt,
  });
}
