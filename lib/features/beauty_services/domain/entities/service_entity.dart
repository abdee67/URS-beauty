class ServiceEntity {
  final int id;
  final String name;
  final String description;
  final String categoryId;
  final int? durationMinutes;
  final double basePrice;
  final double minPrice;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final String iconUrl;

  ServiceEntity({
    required this.id,
    required this.categoryId,
    required this.description,
    required this.durationMinutes,
    required this.iconUrl,
    required this.name,
    required this.basePrice,
    required this.minPrice,
    this.createdAt,
    required this.isActive,
    this.updatedAt,
  });
}
