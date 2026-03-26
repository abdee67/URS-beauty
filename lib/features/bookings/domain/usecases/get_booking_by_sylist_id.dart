import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart';
import 'package:urs_beauty/features/bookings/domain/repositories/booking_repository.dart';

class GetBookingsByStylistId {
  GetBookingsByStylistId(this.repository);

  final BookingRepository repository;

  Future<Either<Failures, List<BookingEntity>>> call(String stylistId) {
    return repository.getBookingsByStylistId(stylistId);
  }
}

class GetBookingBySylistId extends GetBookingsByStylistId {
  GetBookingBySylistId(super.repository);
}
