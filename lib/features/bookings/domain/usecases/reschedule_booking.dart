import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart';
import 'package:urs_beauty/features/bookings/domain/repositories/booking_repository.dart';

class RescheduleBooking {
  final BookingRepository repository;
  RescheduleBooking({required this.repository});

  Future<Either<Failures, BookingEntity>> call(String bookingId, DateTime newDateTime) async {
    return await repository.rescheduleBooking(bookingId, newDateTime);
  }
}