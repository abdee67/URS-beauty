import 'package:urs_beauty/features/bookings/data/models/booking_model.dart';
import 'package:urs_beauty/features/bookings/data/models/booking_services_model.dart';
import 'package:urs_beauty/features/bookings/data/models/create_booking_request_model.dart';

abstract class BookingRemoteDataSource {
  Future<BookingModel> createBooking(BookingModel booking);
  Future<BookingModel> createBookingWithServices(
    CreateBookingRequestModel request,
  );
  Future<BookingModel> updateBooking(BookingModel booking);
  Future<void> cancelBooking(String bookingId);
  Future<List<BookingModel>> getBookings();
  Future<BookingModel> getBookingById(String bookingId);
  Future<List<BookingServicesModel>> getBookingServices(String bookingId);
  Future<List<BookingModel>> getBookingsByCustomerId(String customerId);
  Future<List<BookingModel>> getBookingsByStylistId(String stylistId);
  Future<List<BookingModel>> getBookingsByStatus(String status);
  Future<BookingModel> rescheduleBooking(
    String bookingId,
    DateTime newScheduledAt,
  );
  Future<BookingModel> addNotesToBooking(String bookingId, String notes);
  Future<BookingModel> updateBookingStatus(String bookingId, String status);
  Future<List<BookingModel>> searchBookings(String query);
}
