import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart';
import 'package:urs_beauty/features/bookings/domain/repositories/booking_repository.dart';

class SearchBookings {
  SearchBookings(this.repository);

  final BookingRepository repository;

  Future<Either<Failures, List<BookingEntity>>> call(String query) {
    return repository.searchBookings(query);
  }
}

class SearchBooking extends SearchBookings {
  SearchBooking(super.repository);
}
