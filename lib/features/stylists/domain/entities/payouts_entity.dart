enum PayoutMethod{
  bankTransfer,
  payPal,
  stripe
}
enum PayoutStatus{
  pending,
  processing,
  paid,
  cancelled
}

class PayoutsEntity {
  final String id;
  final String walletId;
  final PayoutStatus status;
  final double amount;
  final PayoutMethod payoutMethod;
  final DateTime createdAt;
  final DateTime updatedAt;

  PayoutsEntity({
    required this.id,
    required this.walletId,
    required this.status,
    required this.amount,
    required this.payoutMethod,
    required this.createdAt,
    required this.updatedAt,
  });
}