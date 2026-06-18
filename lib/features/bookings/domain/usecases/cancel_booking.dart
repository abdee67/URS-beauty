import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart';
import 'package:urs_beauty/features/bookings/domain/repositories/booking_repository.dart';

class CancelBooking {
  CancelBooking(this.repository);

  final BookingRepository repository;

  Future<Either<Failures, BookingEntity>> call(String bookingId) {
    return repository.cancelBooking(bookingId);
  }
}
