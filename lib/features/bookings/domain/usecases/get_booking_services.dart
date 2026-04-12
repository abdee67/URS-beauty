import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_services.dart';
import 'package:urs_beauty/features/bookings/domain/repositories/booking_repository.dart';

class GetBookingServices {
  GetBookingServices(this.repository);

  final BookingRepository repository;

  Future<Either<Failures, List<BookingServicesEntity>>> call(String bookingId) {
    return repository.getBookingServices(bookingId);
  }
}
