import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/bookings/data/models/create_booking_request_model.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_services.dart';

abstract class BookingRepository {
  Future<Either<Failures, BookingEntity>> createBooking(BookingEntity booking);
  Future<Either<Failures, BookingEntity>> createBookingWithServices( CreateBookingRequestModel request);
  Future<Either<Failures, BookingEntity>> updateBooking(BookingEntity booking);
  Future<Either<Failures, void>> cancelBooking(String bookingId);
  Future<Either<Failures, List<BookingEntity>>> getBookings();
  Future<Either<Failures, BookingEntity>> getBookingById(String bookingId);
  Future<Either<Failures, List<BookingEntity>>> getBookingsByCustomerId(String customerId);
  Future<Either<Failures, List<BookingServicesEntity>>> getBookingServices(String bookingId);
  Future<Either<Failures, List<BookingEntity>>> getBookingsByStylistId(String stylistId);
  Future<Either<Failures, List<BookingEntity>>> getBookingsByStatus(String status);
  Future<Either<Failures, BookingEntity>> rescheduleBooking(String bookingId, DateTime newScheduledAt);
  Future<Either<Failures, BookingEntity>> addNotesToBooking(String bookingId, String notes);
  Future<Either<Failures, BookingEntity>> updateBookingStatus(String bookingId, String status);
  Future<Either<Failures, List<BookingEntity>>> searchBookings(String query);

}