class CustomerAddressEntity {
  final String id;
  final String customerId;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomerAddressEntity({
    required this.id,
    required this.customerId,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });
}
