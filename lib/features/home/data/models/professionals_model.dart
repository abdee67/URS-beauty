  import 'package:urs_beauty/features/home/domain/entities/professioanls.dart';

class ProfessionalModel {
  final String id;
  final String buisnessName;
  final String description;
  final double serviceRadiusKm;
  final double rating;
  final String imageUrl;
  final bool isVerified;
  final String reviews;
  final int longitude;
  final int latitude;


  ProfessionalModel({
    required this.id,
    required this.buisnessName,
    required this.description,
    required this.serviceRadiusKm,
    required this.rating,
    required this.imageUrl,
    required this.isVerified,
    required this.reviews,
    required this.longitude,
    required this.latitude,
  });

  factory ProfessionalModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalModel(
      id: json['id'],
      buisnessName: json['buisness_name'],
      description: json['description'],
      serviceRadiusKm: json['service_radius_km']?.toDouble() ?? 0.0,
      rating: json['avg_rating']?.toDouble() ?? 0.0,
      imageUrl: json['image_url'],
      isVerified: json['is_verified'],
      reviews: json['reviews'],
      longitude: json['longitude'],
      latitude: json['latitude'],
    );
  }
  Professionals toEntity() {
    return Professionals(
      id: id,
      buisnessName: buisnessName,
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
