import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart';
import 'package:urs_beauty/features/bookings/domain/repositories/booking_repository.dart';

class AddNotesToBooking {
  final BookingRepository repository;

  AddNotesToBooking({required this.repository});

  Future<Either<Failures, BookingEntity>> call(String bookingId, String notes) async {
    return await repository.addNotesToBooking(bookingId, notes);
  }
}