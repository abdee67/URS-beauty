import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/features/bookings/data/models/create_booking_request_model.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_services.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/add_notes_to_booking.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/cancel_booking.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/create_booking.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/create_booking_with_services.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/get_booking_by_customer_id.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/get_booking_by_status.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/get_booking_by_sylist_id.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/get_booking_services.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/get_bookings.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/get_bookings_by_id.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/reschedule_booking.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/search_booking.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/update_booking.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/update_booking_status.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  BookingBloc({
    required this.createBooking,
    required this.createBookingWithServices,
    required this.updateBooking,
    required this.cancelBooking,
    required this.getBookings,
    required this.getBookingById,
    required this.getBookingsByCustomerId,
    required this.getBookingServices,
    required this.getBookingsByStylistId,
    required this.getBookingsByStatus,
    required this.rescheduleBooking,
    required this.addNotesToBooking,
    required this.updateBookingStatus,
    required this.searchBookings,
  }) : super(const BookingState()) {
    on<CreateBookingEvent>(_onCreateBooking);
    on<CreateBookingWithServicesEvent>(_onCreateBookingWithServices);
    on<UpdateBookingEvent>(_onUpdateBooking);
    on<CancelBookingEvent>(_onCancelBooking);
    on<GetBookingsEvent>(_onGetBookings);
    on<GetBookingByIdEvent>(_onGetBookingById);
    on<GetBookingsByCustomerIdEvent>(_onGetBookingsByCustomerId);
    on<GetBookingServicesEvent>(_onGetBookingServices);
    on<GetBookingsByStylistIdEvent>(_onGetBookingsByStylistId);
    on<GetBookingsByStatusEvent>(_onGetBookingsByStatus);
    on<RescheduleBookingEvent>(_onRescheduleBooking);
    on<AddNotesToBookingEvent>(_onAddNotesToBooking);
    on<UpdateBookingStatusEvent>(_onUpdateBookingStatus);
    on<SearchBookingsEvent>(_onSearchBookings);
    on<ClearBookingMessageEvent>(_onClearBookingMessage);
  }

  final CreateBooking createBooking;
  final CreateBookingWithServices createBookingWithServices;
  final UpdateBooking updateBooking;
  final CancelBooking cancelBooking;
  final GetBookings getBookings;
  final GetBookingById getBookingById;
  final GetBookingsByCustomerId getBookingsByCustomerId;
  final GetBookingServices getBookingServices;
  final GetBookingsByStylistId getBookingsByStylistId;
  final GetBookingsByStatus getBookingsByStatus;
  final RescheduleBooking rescheduleBooking;
  final AddNotesToBooking addNotesToBooking;
  final UpdateBookingStatus updateBookingStatus;
  final SearchBookings searchBookings;

  Future<void> _onCreateBooking(
    CreateBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.creating());

    final result = await createBooking(event.booking);
    result.fold(
      (failure) => emit(state.failure(failure.message)),
      (booking) => emit(
        state.copyWith(
          status: BookingBlocStatus.created,
          selectedBooking: booking,
          message: 'Booking created successfully.',
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onCreateBookingWithServices(
    CreateBookingWithServicesEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.creating());

    final result = await createBookingWithServices(event.request);
    result.fold(
      (failure) => emit(state.failure(failure.message)),
      (booking) => emit(
        state.copyWith(
          status: BookingBlocStatus.created,
          selectedBooking: booking,
          message: 'Booking created successfully.',
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onUpdateBooking(
    UpdateBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.updating());

    final result = await updateBooking(event.booking);
    result.fold(
      (failure) => emit(state.failure(failure.message)),
      (booking) => emit(
        state.copyWith(
          status: BookingBlocStatus.updated,
          selectedBooking: booking,
          message: 'Booking updated successfully.',
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onCancelBooking(
    CancelBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.cancelling());

    final result = await cancelBooking(event.bookingId);
    result.fold(
      (failure) => emit(state.failure(failure.message)),
      (_) => emit(
        state.copyWith(
          status: BookingBlocStatus.cancelled,
          message: 'Booking cancelled successfully.',
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onGetBookings(
    GetBookingsEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.loading());

    final result = await getBookings();
    result.fold(
      (failure) => emit(state.failure(failure.message)),
      (bookings) => emit(
        state.copyWith(
          status: BookingBlocStatus.loaded,
          bookings: bookings,
          message: 'Bookings loaded successfully.',
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onGetBookingById(
    GetBookingByIdEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.loading());

    final result = await getBookingById(event.bookingId);
    result.fold(
      (failure) => emit(state.failure(failure.message)),
      (booking) => emit(
        state.copyWith(
          status: BookingBlocStatus.loaded,
          selectedBooking: booking,
          message: 'Booking loaded successfully.',
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onGetBookingsByCustomerId(
    GetBookingsByCustomerIdEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.loading());

    final result = await getBookingsByCustomerId(event.customerId);
    result.fold(
      (failure) => emit(state.failure(failure.message)),
      (bookings) => emit(
        state.copyWith(
          status: BookingBlocStatus.loaded,
          customerBookings: bookings,
          message: 'Customer bookings loaded successfully.',
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onGetBookingServices(
    GetBookingServicesEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.servicesLoading());

    final result = await getBookingServices(event.bookingId);
    result.fold(
      (failure) => emit(state.failure(failure.message)),
      (services) => emit(
        state.copyWith(
          status: BookingBlocStatus.servicesLoaded,
          bookingServices: services,
          message: 'Booking services loaded successfully.',
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onGetBookingsByStylistId(
    GetBookingsByStylistIdEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.loading());

    final result = await getBookingsByStylistId(event.stylistId);
    result.fold(
      (failure) => emit(state.failure(failure.message)),
      (bookings) => emit(
        state.copyWith(
          status: BookingBlocStatus.loaded,
          stylistBookings: bookings,
          message: 'Stylist bookings loaded successfully.',
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onGetBookingsByStatus(
    GetBookingsByStatusEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.loading());

    final result = await getBookingsByStatus(event.status);
    result.fold(
      (failure) => emit(state.failure(failure.message)),
      (bookings) => emit(
        state.copyWith(
          status: BookingBlocStatus.loaded,
          statusBookings: bookings,
          message: 'Bookings loaded successfully.',
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onRescheduleBooking(
    RescheduleBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.updating());

    final result = await rescheduleBooking(
      event.bookingId,
      event.newScheduledAt,
    );
    result.fold(
      (failure) => emit(state.failure(failure.message)),
      (booking) => emit(
        state.copyWith(
          status: BookingBlocStatus.updated,
          selectedBooking: booking,
          message: 'Booking rescheduled successfully.',
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onAddNotesToBooking(
    AddNotesToBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.updating());

    final result = await addNotesToBooking(event.bookingId, event.notes);
    result.fold(
      (failure) => emit(state.failure(failure.message)),
      (booking) => emit(
        state.copyWith(
          status: BookingBlocStatus.updated,
          selectedBooking: booking,
          message: 'Booking notes updated successfully.',
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onUpdateBookingStatus(
    UpdateBookingStatusEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.updating());

    final result = await updateBookingStatus(event.bookingId, event.status);
    result.fold(
      (failure) => emit(state.failure(failure.message)),
      (booking) => emit(
        state.copyWith(
          status: BookingBlocStatus.updated,
          selectedBooking: booking,
          message: 'Booking status updated successfully.',
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onSearchBookings(
    SearchBookingsEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.searching(event.query));

    final result = await searchBookings(event.query);
    result.fold(
      (failure) => emit(state.failure(failure.message)),
      (bookings) => emit(
        state.copyWith(
          status: BookingBlocStatus.searched,
          searchedBookings: bookings,
          query: event.query,
          message: 'Search completed successfully.',
          clearError: true,
        ),
      ),
    );
  }

  void _onClearBookingMessage(
    ClearBookingMessageEvent event,
    Emitter<BookingState> emit,
  ) {
    emit(state.copyWith(clearMessage: true, clearError: true));
  }
}
