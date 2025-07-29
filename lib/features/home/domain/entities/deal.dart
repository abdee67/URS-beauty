class Deal {
  final String id;
  final String title;
  final String description;
  final double originalPrice;
  final double discountedPrice;
  final String serviceName;
  final String serviceCategory;
  final String imageUrl;

  Deal({
    required this.id,
    required this.title,
    required this.description,
    required this.originalPrice,
    required this.discountedPrice,
    required this.serviceName,
    required this.serviceCategory,
    required this.imageUrl,
  });
}