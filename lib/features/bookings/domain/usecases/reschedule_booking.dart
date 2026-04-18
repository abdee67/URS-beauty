import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart';
import 'package:urs_beauty/features/bookings/domain/entities/reschedule_booking_request.dart';
import 'package:urs_beauty/features/bookings/domain/repositories/booking_repository.dart';

class RescheduleBooking {
  final BookingRepository repository;
  RescheduleBooking({required this.repository});

  Future<Either<Failures, BookingEntity>> call(
    RescheduleBookingRequestEntity request,
  ) async {
    return await repository.rescheduleBooking(request);
  }
}
