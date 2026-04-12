class StylistsServiceEntity {
  final String id;
  final String serviceId;
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
