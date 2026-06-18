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
    super.createdAt,
    super.updatedAt,
  });

  factory StylistModel.fromJson(Map<String, dynamic> json) {
    return StylistModel(
      id: json['id'] ?? '',
      businessName: json['business_name'] ?? '',
      description: json['description'] ?? '',
      serviceRadiusKm: json['service_radius_km']?.toDouble() ?? 0.0,
      averageRating: json['avg_rating']?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] ?? '',
      isVerified: json['is_verified'] ?? false,
      totalReview: json['total_reviews'] ?? 0,
      longitude: json['longitude'] ?? 0,
      latitude: json['latitude'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
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
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
