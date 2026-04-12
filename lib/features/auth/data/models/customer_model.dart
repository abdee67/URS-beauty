import 'package:urs_beauty/features/auth/data/models/customer_address_model.dart';
import 'package:urs_beauty/features/auth/domain/entities/customer_entity.dart';

class CustomerModel extends CustomerEntity {
  CustomerModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.phone,
    super.profileImage,
    super.addresses,
    super.createdAt,
    super.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    final metadata = json['user_metadata'] is Map
        ? Map<String, dynamic>.from(json['user_metadata'] as Map)
        : <String, dynamic>{};
    final addressesJson =
        json['addresses'] ?? json['customer_address'] ?? const [];
    final addresses = addressesJson is List
        ? addressesJson
            .whereType<Map>()
            .map(
              (item) => CustomerAddressModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : <CustomerAddressModel>[];

    return CustomerModel(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      firstName: (json['first_name'] ?? metadata['first_name'] ?? '').toString(),
      lastName: (json['last_name'] ?? metadata['last_name'] ?? '').toString(),
      phone: _asInt(json['phone_number'] ?? metadata['phone_number']),
      profileImage: (json['profile_image_url'] ?? '').toString(),
      addresses: addresses,
      createdAt: _asDateTime(json['created_at']),
      updatedAt: _asDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phone,
      'profile_image_url': profileImage,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'addresses': addresses
          .whereType<CustomerAddressModel>()
          .map((address) => address.toJson())
          .toList(),
    };
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
