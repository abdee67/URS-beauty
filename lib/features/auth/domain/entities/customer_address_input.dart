class CustomerAddressInput {
  const CustomerAddressInput({
    required this.addressLine1,
    this.addressLine2 = '',
    required this.city,
    this.state = '',
    this.postalCode = '',
    required this.country,
    this.latitude = 0,
    this.longitude = 0,
  });

  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final double latitude;
  final double longitude;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'address_line1': addressLine1.trim(),
      'address_line2': addressLine2.trim(),
      'city': city.trim(),
      'state': state.trim(),
      'postal_code': postalCode.trim(),
      'country': country.trim(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
