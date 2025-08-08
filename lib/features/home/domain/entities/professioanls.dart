class Professionals {
  final String id;
  final String businessName;
  final String description;
  final double serviceRadiusKm;
  final double rating;
  final String imageUrl;
  final bool isVerified;
  final String reviews;
  final int longitude;
  final int latitude;

  Professionals({
    required this.id,
    required this.businessName,
    required this.description,
    required this.serviceRadiusKm,
    required this.rating,
    required this.imageUrl,
    required this.isVerified,
    required this.reviews,
    required this.longitude,
    required this.latitude,
  });
}
