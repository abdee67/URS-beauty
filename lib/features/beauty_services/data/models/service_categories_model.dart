import 'package:urs_beauty/features/beauty_services/domain/entities/service_category_entity.dart';


class ServiceCategoriesModel extends ServiceCategories {
  ServiceCategoriesModel({
    required super.id,
    required super.name,
    required super.description,
    required super.iconUrl,
    required super.isActive,
  });

  factory ServiceCategoriesModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoriesModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['icon_url'] ?? '',
      isActive: json['is_active'] ?? false,
    );
  }
  ServiceCategories toEntity() {
    return ServiceCategories(
      id: id,
      name: name,
      description: description,
      iconUrl: iconUrl,
      isActive: isActive,
    );
  }
}
