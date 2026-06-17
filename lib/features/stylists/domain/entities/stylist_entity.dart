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
  final int userId;
  final String onboardingStatus;
  final int yearsOfExperience;
  final String? rejectionReason;
  final double distanceKm;
  final double servicePrice;
  final int serviceDuration;
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
    required this.userId,
    required this.onboardingStatus,
    required this.yearsOfExperience,
    required this.rejectionReason,
    required this.servicePrice,
    required this.serviceDuration,
    required this.distanceKm,
    this.createdAt,
    this.updatedAt,
  });
    String get distanceDisplay => distanceKm < 1
      ? '${(distanceKm * 1000).round()} m away'
      : '${distanceKm.toStringAsFixed(1)} km away';

  List<Object?> get props =>
      [id, businessName, distanceKm, servicePrice, averageRating];
}
