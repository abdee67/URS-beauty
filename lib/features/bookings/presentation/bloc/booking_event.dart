part of 'booking_bloc.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class CreateBookingEvent extends BookingEvent {
  const CreateBookingEvent(this.booking);

  final BookingEntity booking;

  @override
  List<Object?> get props => [booking];
}

class CreateBookingWithServicesEvent extends BookingEvent {
  const CreateBookingWithServicesEvent(this.request);

  final CreateBookingRequestModel request;

  @override
  List<Object?> get props => [request];
}

class UpdateBookingEvent extends BookingEvent {
  const UpdateBookingEvent(this.booking);

  final BookingEntity booking;

  @override
  List<Object?> get props => [booking];
}

class CancelBookingEvent extends BookingEvent {
  const CancelBookingEvent(this.bookingId);

  final String bookingId;

  @override
  List<Object?> get props => [bookingId];
}

class GetBookingsEvent extends BookingEvent {
  const GetBookingsEvent();
}

class GetBookingByIdEvent extends BookingEvent {
  const GetBookingByIdEvent(this.bookingId);

  final String bookingId;

  @override
  List<Object?> get props => [bookingId];
}

class GetBookingsByCustomerIdEvent extends BookingEvent {
  const GetBookingsByCustomerIdEvent(this.customerId);

  final String customerId;

  @override
  List<Object?> get props => [customerId];
}

class GetBookingServicesEvent extends BookingEvent {
  const GetBookingServicesEvent(this.bookingId);

  final String bookingId;

  @override
  List<Object?> get props => [bookingId];
}

class GetBookingsByStylistIdEvent extends BookingEvent {
  const GetBookingsByStylistIdEvent(this.stylistId);

  final String stylistId;

  @override
  List<Object?> get props => [stylistId];
}

class GetBookingsByStatusEvent extends BookingEvent {
  const GetBookingsByStatusEvent(this.status);

  final String status;

  @override
  List<Object?> get props => [status];
}

class RescheduleBookingEvent extends BookingEvent {
  const RescheduleBookingEvent(this.bookingId, this.newScheduledAt);

  final String bookingId;
  final DateTime newScheduledAt;

  @override
  List<Object?> get props => [bookingId, newScheduledAt];
}

class AddNotesToBookingEvent extends BookingEvent {
  const AddNotesToBookingEvent(this.bookingId, this.notes);

  final String bookingId;
  final String notes;

  @override
  List<Object?> get props => [bookingId, notes];
}

class UpdateBookingStatusEvent extends BookingEvent {
  const UpdateBookingStatusEvent(this.bookingId, this.status);

  final String bookingId;
  final String status;

  @override
  List<Object?> get props => [bookingId, status];
}

class SearchBookingsEvent extends BookingEvent {
  const SearchBookingsEvent(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class ClearBookingMessageEvent extends BookingEvent {
  const ClearBookingMessageEvent();
}
