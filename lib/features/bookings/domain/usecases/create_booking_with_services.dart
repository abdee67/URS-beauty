import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/bookings/data/models/create_booking_request_model.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart';
import 'package:urs_beauty/features/bookings/domain/repositories/booking_repository.dart';

class CreateBookingWithServices {
  CreateBookingWithServices(this.repository);

  final BookingRepository repository;

  Future<Either<Failures, BookingEntity>> call(
    CreateBookingRequestModel request,
  ) {
    return repository.createBookingWithServices(request);
  }
}
