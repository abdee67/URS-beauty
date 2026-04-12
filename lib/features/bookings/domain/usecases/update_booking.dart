import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart';
import 'package:urs_beauty/features/bookings/domain/repositories/booking_repository.dart';

class UpdateBooking {
  final BookingRepository repository;
  UpdateBooking({required this.repository});

  Future<Either<Failures, BookingEntity>> call( BookingEntity updatedBooking) async {
    return await repository.updateBooking( updatedBooking);
  }
}