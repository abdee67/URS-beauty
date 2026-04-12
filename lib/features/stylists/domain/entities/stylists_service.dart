class StylistsServiceEntity {
  final int id;
  final int serviceId;
  final String stylistsId;
  final double price;
  final bool isAvailable;

  StylistsServiceEntity({
    required this.id,
    required this.serviceId,
    required this.stylistsId,
    required this.price,
    required this.isAvailable,
  });
}