import 'package:urs_beauty/features/home/domain/entities/services.dart';

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String minPrice;
  final String basePrice;
  final String duration;
  final bool isActive;
  final String professionalId;
  final String serviceCategoryId;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.minPrice,
    required this.basePrice,
    required this.duration,
    required this.isActive,
    required this.professionalId,
    required this.serviceCategoryId,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconUrl: json['icon_url'],
      minPrice: json['min_price'],
      basePrice: json['base_price'],
      duration: json['duration_minutes'],
      isActive: json['is_active'],
      professionalId: json['professional_id'],
      serviceCategoryId: json['category_id'],
    );
  }
  Services toEntity() {
    return Services(
      id: id,
      name: name,
      description: description,
      iconUrl: iconUrl,
      minPrice: minPrice,
      basePrice: basePrice,
      duration: duration,
      isActive: isActive,
      professionalId: professionalId,
      serviceCategoryId: serviceCategoryId,
    );
  }
}
