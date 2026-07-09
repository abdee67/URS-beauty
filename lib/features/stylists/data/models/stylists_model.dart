import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';
import 'package:urs_beauty/core/constants/app_strings.dart';

class StylistModel extends Stylist {
  StylistModel({
    required super.id,
    required super.businessName,
    required super.description,
    required super.serviceRadiusKm,
    required super.averageRating,
    required super.imageUrl,
    required super.isVerified,
    required super.totalReview,
    required super.longitude,
    required super.latitude,
    required super.userId,
    required super.onboardingStatus,
    required super.yearsOfExperience,
    required super.rejectionReason,
    required super.distanceKm,
    required super.servicePrice,
    required super.serviceDuration,
    super.createdAt,
    super.updatedAt,
  });

  factory StylistModel.fromJson(Map<String, dynamic> json) {
    return StylistModel(
      id: AppStrings.asString(json['stylist_id'] ?? json['id']),
      businessName: AppStrings.asString(json['business_name']),
      description: AppStrings.asString(json['description']),
      serviceRadiusKm: AppStrings.asDouble(json['service_radius_km']),
      averageRating: AppStrings.asDouble(json['avg_rating']),
      imageUrl: json['image_url'] == 'null' || json['image_url'] == null
          ? null
          : AppStrings.asString(json['image_url']),
      isVerified: json['is_verified'] ?? false,
      totalReview: AppStrings.asInt(json['total_reviews']),
      longitude: AppStrings.asDouble(json['longitude']),
      latitude: AppStrings.asDouble(json['latitude']),
      userId: AppStrings.asInt(json['user_id']),
      onboardingStatus: AppStrings.asString(
        json['onboarding_status'] ?? 'pending',
      ),
      yearsOfExperience: AppStrings.asInt(json['years_experience'] ?? 0),
      rejectionReason: AppStrings.asString(json['rejection_reason'] ?? ''),
      distanceKm: AppStrings.asDouble(json['distance_km'] ?? 0),
      servicePrice: AppStrings.asDouble(json['service_price'] ?? 0),
      serviceDuration: AppStrings.asInt(json['service_duration'] ?? 0),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_name': businessName,
      'description': description,
      'service_radius_km': serviceRadiusKm,
      'avg_rating': averageRating,
      'image_url': imageUrl,
      'is_verified': isVerified,
      'total_reviews': totalReview,
      'longitude': longitude,
      'latitude': latitude,
      'user_id': userId,
      'onboarding_status': onboardingStatus,
      'years_experience': yearsOfExperience,
      'rejection_reason': rejectionReason,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Stylist toEntity() {
    return Stylist(
      id: id,
      businessName: businessName,
      description: description,
      serviceRadiusKm: serviceRadiusKm,
      averageRating: averageRating,
      imageUrl: imageUrl,
      isVerified: isVerified,
      totalReview: totalReview,
      longitude: longitude,
      latitude: latitude,
      userId: userId,
      onboardingStatus: onboardingStatus,
      yearsOfExperience: yearsOfExperience,
      rejectionReason: rejectionReason,
      distanceKm: distanceKm,
      servicePrice: servicePrice,
      serviceDuration: serviceDuration,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
