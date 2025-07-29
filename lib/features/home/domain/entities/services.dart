class Services{
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String minPrice;
  final String basePrice;
  final String duration;
  final bool isActive;
  final String professionalId;
  final String serviceCategoryId;

  Services({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.minPrice,
    required this.basePrice,
    required this.duration,
    required this.isActive,
    required this.professionalId,
    required this.serviceCategoryId,
  });
}