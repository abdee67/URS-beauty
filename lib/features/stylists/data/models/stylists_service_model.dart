import 'package:urs_beauty/features/stylists/domain/entities/stylists_service.dart';

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
      id: json['id'],
      serviceId: json['service_id'],
      stylistsId: json['stylists_id'],
      price: (json['price'] as num).toDouble(),
      isAvailable: json['is_available'] ?? false,
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