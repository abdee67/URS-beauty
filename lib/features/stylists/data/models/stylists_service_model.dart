import 'package:urs_beauty/features/stylists/domain/entities/stylists_service.dart';
import 'package:urs_beauty/core/constants/app_strings.dart';

class StylistsServiceModel extends StylistsServiceEntity {
  StylistsServiceModel({
    required super.id,
    required super.serviceId,
    required super.stylistsId,
    required super.price,
    required super.isAvailable,
  });

  factory StylistsServiceModel.fromJson(Map<String, dynamic> json) {
    return StylistsServiceModel(
      id: AppStrings.asString(json['id'] ?? ''),
      serviceId: AppStrings.asString(json['service_id'] ?? ''),
      stylistsId: AppStrings.asString(json['stylists_id'] ?? ''),
      price: AppStrings.asDouble(json['price'] as num?),
      isAvailable: AppStrings.asBool(json['is_available']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'stylists_id': stylistsId,
      'price': price,
      'is_available': isAvailable,
    };
  }
}
