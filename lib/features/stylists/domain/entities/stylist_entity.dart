class Stylist {
  final String id;
  final String businessName;
  final String description;
  final double serviceRadiusKm;
  final double averageRating;
  final String imageUrl;
  final bool isVerified;
  final String reviews;
  final int longitude;
  final int latitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Stylist({
    required this.id,
    required this.businessName,
    required this.description,
    required this.serviceRadiusKm,
    required this.averageRating,
    required this.imageUrl,
    required this.isVerified,
    required this.reviews,
    required this.longitude,
    required this.latitude,
    this.createdAt,
    this.updatedAt,
  });
}
