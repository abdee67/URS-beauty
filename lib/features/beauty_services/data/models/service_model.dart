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
      id: _asString(json['id']),
      name: _asString(json['name']),
      description: _asString(json['description']),
      iconUrl: _asString(json['icon_url']),
      categoryId: (json['category_id'] ?? '').toString(),
      basePrice: _asDouble(json['base_price']),
      minPrice: _asDouble(json['min_price']),
      durationMinutes: _asNullableInt(json['duration_minutes']),
      createdAt: _asDateTime(json['created_at']),
      updatedAt: _asDateTime(json['updated_at']),
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
    return value.toString().trim();
  }

  static int? _asNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }
    return _asInt(value);
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

  static DateTime? _asDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value.trim());
    }
    return null;
  }
}
