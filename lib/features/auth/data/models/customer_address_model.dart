import 'package:urs_beauty/features/auth/domain/entities/customer_address_entity.dart';

class CustomerAddressModel extends CustomerAddressEntity {
  CustomerAddressModel({
    required super.id,
    required super.customerId,
    required super.addressLine1,
    required super.addressLine2,
    required super.city,
    required super.state,
    required super.postalCode,
    required super.country,
    required super.latitude,
    required super.longitude,
    required super.isDefault,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CustomerAddressModel.fromJson(Map<String, dynamic> json) {
    return CustomerAddressModel(
      id: (json['id'] ?? '').toString(),
      customerId: (json['customer_id'] ?? '').toString(),
      addressLine1: (json['address_line1'] ?? '').toString(),
      addressLine2: (json['address_line2'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      postalCode: (json['postal_code'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      isDefault: json['is_default'] == true,
      createdAt: _asDateTime(json['created_at']),
      updatedAt: _asDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'customer_id': customerId,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
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

  static DateTime _asDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value.trim()) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
