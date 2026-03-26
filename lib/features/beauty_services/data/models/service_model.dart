//get the mf service model bihhhhhhh
import 'package:urs_beauty/features/beauty_services/domain/entities/service_entity.dart';

class ServiceModel extends ServiceEntity {
  ServiceModel({
required super.id,
required super.name,
required super.description,
required super.categoryId,
required super.durationMinutes,
required super.iconUrl,
required super.basePrice,
required super.createdAt,
required super.updatedAt,
required super.minPrice,
required super.isActive,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['icon_url'] ?? '',
      categoryId: json['category_id'],
      basePrice: json['base_price'],
      minPrice: json['min_price'],
      durationMinutes: json['duration_minutes'],
      createdAt: json['created_ar]at'],
      updatedAt: json['updated_at'],
      isActive: json['is_active'] ?? false,
    );
  }
  ServiceModel toEntity() {
    return ServiceModel(
      id: id,
      name: name,
      description: description,
      basePrice: basePrice,
      categoryId: categoryId,
      durationMinutes: durationMinutes,
      minPrice: minPrice,
      createdAt: createdAt,
      updatedAt: updatedAt,
      iconUrl: iconUrl,
      isActive: isActive,
    );
  } 
}