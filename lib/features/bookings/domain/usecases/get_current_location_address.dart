import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/auth/domain/entities/customer_address_input.dart';
import 'package:urs_beauty/features/bookings/domain/repositories/booking_repository.dart';

class GetCurrentLocationAddress {
  const GetCurrentLocationAddress(this.repository);

  final BookingRepository repository;

  Future<Either<Failures, CustomerAddressInput>> call() {
    return repository.getCurrentLocationAddress();
  }
}
