class WalletsEntity {
  final String id;
  final String stylistId;
  final double balance;
  final String currency;
  final DateTime createdAt;

  WalletsEntity({
    required this.id,
    required this.stylistId,
    required this.balance,
    required this.currency,
    required this.createdAt,
  });
}