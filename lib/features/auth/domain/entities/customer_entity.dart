import 'package:urs_beauty/features/auth/domain/entities/customer_address_entity.dart';

class CustomerEntity {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String profileImage;
  final int phone;
  final List<CustomerAddressEntity> addresses;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CustomerEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.profileImage = '',
    this.addresses = const [],
    this.createdAt,
    this.updatedAt,
  });

  CustomerAddressEntity? get defaultAddress {
    for (final address in addresses) {
      if (address.isDefault) {
        return address;
      }
    }

    if (addresses.isEmpty) {
      return null;
    }

    return addresses.first;
  }
}
