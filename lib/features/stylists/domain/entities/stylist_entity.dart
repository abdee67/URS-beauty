class Stylist {
  final String id;
  final String businessName;
  final String description;
  final double serviceRadiusKm;
  final double averageRating;
  final String imageUrl;
  final bool isVerified;
  final int totalReview;
  final double longitude;
  final double latitude;
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
    required this.totalReview,
    required this.longitude,
    required this.latitude,
    this.createdAt,
    this.updatedAt,
  });
}
