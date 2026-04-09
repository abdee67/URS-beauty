import 'package:urs_beauty/features/auth/domain/entities/customer_address_input.dart';

abstract class BookingLocationDataSource {
  Future<CustomerAddressInput> getCurrentLocationAddress();
}
