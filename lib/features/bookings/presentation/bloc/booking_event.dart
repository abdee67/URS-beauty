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

  final CreateBookingRequestEntity request;

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

class LoadMyBookingsEvent extends BookingEvent {
  const LoadMyBookingsEvent();
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

  final BookingStatus status;

  @override
  List<Object?> get props => [status];
}

class StartRescheduleFlowEvent extends BookingEvent {
  const StartRescheduleFlowEvent(this.booking);

  final BookingEntity booking;

  @override
  List<Object?> get props => [booking];
}

class RescheduleBookingEvent extends BookingEvent {
  const RescheduleBookingEvent(this.request);

  final RescheduleBookingRequestEntity request;

  @override
  List<Object?> get props => [request];
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

class CreateCustomerAddressEvent extends BookingEvent {
  const CreateCustomerAddressEvent(this.input);

  final CustomerAddressInput input;

  @override
  List<Object?> get props => [input];
}

class UseCurrentLocationAddressEvent extends BookingEvent {
  const UseCurrentLocationAddressEvent();
}

class SelectBookingAddressEvent extends BookingEvent {
  const SelectBookingAddressEvent(this.addressId);

  final String addressId;

  @override
  List<Object?> get props => [addressId];
}

class ConfirmBookingEvent extends BookingEvent {
  const ConfirmBookingEvent({
    required this.serviceId,
    required this.stylistId,
    required this.scheduledAt,
    this.notes,
  });

  final String serviceId;
  final String stylistId;
  final DateTime scheduledAt;
  final String? notes;

  @override
  List<Object?> get props => [serviceId, stylistId, scheduledAt, notes];
}

class ClearBookingMessageEvent extends BookingEvent {
  const ClearBookingMessageEvent();
}

class SelectDateEvent extends BookingEvent {
  const SelectDateEvent(this.date);

  final DateTime date;

  @override
  List<Object?> get props => [date];
}

class SelectTimeEvent extends BookingEvent {
  const SelectTimeEvent(this.time);  

  final String time;

  @override
  List<Object?> get props => [time];
}

class LoadBookingContextEvent extends BookingEvent {
  final String serviceId;
  final String stylistId;
  const LoadBookingContextEvent( this.serviceId, this.stylistId);

  @override
  List<Object?> get props => [serviceId, stylistId];
}
