import 'package:urs_beauty/features/professionals/domain/entities/professioanls.dart';

class ProfessionalModel extends Professionals {

  ProfessionalModel({
    required super.id,
    required super.businessName,
    required super.description,
    required super.serviceRadiusKm,
    required super.rating,
    required super.imageUrl,
    required super.isVerified,
    required super.reviews,
    required super.longitude,
    required super.latitude,
  });

  factory ProfessionalModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalModel(
      id: json['id'] ?? '',
      businessName: json['business_name'] ?? '',
      description: json['description'] ?? '',
      serviceRadiusKm: json['service_radius_km']?.toDouble() ?? 0.0,
      rating: json['avg_rating']?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] ?? '',
      isVerified: json['is_verified'] ?? false,
      reviews: json['reviews'] ?? '',
      longitude: json['longitude'] ?? 0,
      latitude: json['latitude'] ?? 0,
    );
  }
  Professionals toEntity() {
    return Professionals(
      id: id,
      businessName: businessName,
      description: description,
      serviceRadiusKm: serviceRadiusKm,
      rating: rating,
      imageUrl: imageUrl,
      isVerified: isVerified,
      reviews: reviews,
      longitude: longitude,
      latitude: latitude,
    );
  }
}
