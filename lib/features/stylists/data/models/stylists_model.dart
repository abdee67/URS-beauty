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
    required super.reviews,
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
      reviews: json['reviews'] ?? '',
      longitude: json['longitude'] ?? 0,
      latitude: json['latitude'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
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
      reviews: reviews,
      longitude: longitude,
      latitude: latitude,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
