import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';

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

  String get stylistId => id;

  String get distanceDisplay {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m away';
    }
    return '${distanceKm.toStringAsFixed(1)} km away';
  }

  factory StylistModel.fromJson(Map<String, dynamic> json) {
    return StylistModel(
      id: _asString(json['stylist_id'] ?? json['id']),
      businessName: _asString(json['business_name']),
      description: _asString(json['description']),
      serviceRadiusKm: _asDouble(json['service_radius_km']),
      averageRating: _asDouble(json['avg_rating']),
      imageUrl: _asString(json['image_url']),
      isVerified: json['is_verified'] ?? false,
      totalReview: _asInt(json['total_reviews']),
      longitude: _asDouble(json['longitude']),
      latitude: _asDouble(json['latitude']),
      userId: _asInt(json['user_id']),
      onboardingStatus: _asString(json['onboarding_status'] ?? 'pending'),
      yearsOfExperience: _asInt(json['years_experience'] ?? 0),
      rejectionReason: _asString(json['rejection_reason'] ?? ''),
      distanceKm: _asDouble(json['distance_km'] ?? 0),
      servicePrice: _asDouble(json['service_price'] ?? 0),
      serviceDuration: _asInt(json['service_duration'] ?? 0),
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

  static double _asDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String && value.trim().isNotEmpty) {
      return double.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String && value.trim().isNotEmpty) {
      return int.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }

  static String _asString(dynamic value) {
    if (value == null) {
      return '';
    }
    if (value is String) {
      return value.trim();
    }
    return value.toString().trim();
  }
}
