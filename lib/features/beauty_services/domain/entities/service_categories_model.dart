import 'package:urs_beauty/features/home/domain/entities/services.dart';

class ServiceCategoriesModel {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final bool isActive;

  ServiceCategoriesModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.isActive,
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
