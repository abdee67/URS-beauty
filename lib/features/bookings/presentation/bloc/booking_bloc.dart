import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/features/auth/domain/usecases/get_current_client.dart';
import 'package:urs_beauty/features/auth/domain/usecases/create_customer_address.dart';
import 'package:urs_beauty/features/auth/domain/entities/customer_address_entity.dart';
import 'package:urs_beauty/features/auth/domain/entities/customer_address_input.dart';
import 'package:urs_beauty/features/auth/domain/entities/customer_entity.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylists_service.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart';
import 'package:urs_beauty/features/bookings/domain/entities/create_booking_request.dart';
import 'package:urs_beauty/features/bookings/domain/entities/create_booking_service_item.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_services.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/add_notes_to_booking.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/cancel_booking.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/create_booking.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/create_booking_with_services.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/get_current_location_address.dart';
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
import 'package:urs_beauty/features/stylists/domain/usecases/get_stylist_services.dart';

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
    required this.createCustomerAddress,
    required this.getCurrentLocationAddress,
    required this.getCurrentCustomer,
    required this.getStylistServices,
  }) : super(const BookingState()) {
    on<CreateBookingEvent>(_onCreateBooking);
    on<CreateBookingWithServicesEvent>(_onCreateBookingWithServices);
    on<UpdateBookingEvent>(_onUpdateBooking);
    on<CancelBookingEvent>(_onCancelBooking);
    on<LoadMyBookingsEvent>(_onLoadMyBookings);
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
    on<CreateCustomerAddressEvent>(_onCreateCustomerAddress);
    on<UseCurrentLocationAddressEvent>(_onUseCurrentLocationAddress);
    on<SelectBookingAddressEvent>(_onSelectBookingAddress);
    on<ConfirmBookingEvent>(_onConfirmBooking);
    on<ClearBookingMessageEvent>(_onClearBookingMessage);
    on<SelectDateEvent>(_onSelectDate);
    on<SelectTimeEvent>(_onSelectTime);
    on<LoadBookingContextEvent>(_onLoadBookingContext);
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
  final CreateCustomerAddress createCustomerAddress;
  final GetCurrentLocationAddress getCurrentLocationAddress;
  final GetCurrentCustomer getCurrentCustomer;
  final GetStylistServices getStylistServices;

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
          customerBookings: _markBookingCancelled(
            state.customerBookings,
            event.bookingId,
          ),
          message: 'Booking cancelled successfully.',
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onLoadMyBookings(
    LoadMyBookingsEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.loading());

    final customerResult = await getCurrentCustomer();
    customerResult.fold(
      (failure) => emit(state.failure(failure.message)),
      (customer) {
        emit(
          state.copyWith(
            customer: customer,
            clearError: true,
          ),
        );
        add(GetBookingsByCustomerIdEvent(customer.id));
      },
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
    if (result.isLeft()) {
      result.fold(
        (failure) => emit(state.failure(failure.message)),
        (_) => null,
      );
      return;
    }

    final bookings = result.fold((_) => <BookingEntity>[], (items) => items);
    final syncedBookings = await _syncExpiredBookings(bookings);
    emit(
      state.copyWith(
        status: BookingBlocStatus.loaded,
        customerBookings: syncedBookings,
        message: 'Customer bookings loaded successfully.',
        clearError: true,
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
          customerBookings: _mergeUpdatedBooking(
            state.customerBookings,
            booking,
          ),
          bookings: _mergeUpdatedBooking(state.bookings, booking),
          stylistBookings: _mergeUpdatedBooking(state.stylistBookings, booking),
          statusBookings: _mergeUpdatedBooking(state.statusBookings, booking),
          searchedBookings: _mergeUpdatedBooking(
            state.searchedBookings,
            booking,
          ),
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

  Future<void> _onCreateCustomerAddress(
    CreateCustomerAddressEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.addressCreating());

    final result = await createCustomerAddress(event.input);
    result.fold(
      (failure) => emit(state.failure(failure.message)),
      (address) => emit(
        state.copyWith(
          status: BookingBlocStatus.addressCreated,
          createdAddress: address,
          addresses: _mergeAddresses(state.addresses, address),
          selectedAddressId: address.id,
          message: 'Address saved successfully.',
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onUseCurrentLocationAddress(
    UseCurrentLocationAddressEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.addressCreating());

    final locationResult = await getCurrentLocationAddress();
    if (locationResult.isLeft()) {
      locationResult.fold(
        (failure) => emit(state.failure(failure.message)),
        (_) => null,
      );
      return;
    }

    final input = locationResult.fold((_) => null, (value) => value)!;
    add(CreateCustomerAddressEvent(input));
  }

  void _onSelectBookingAddress(
    SelectBookingAddressEvent event,
    Emitter<BookingState> emit,
  ) {
    emit(
      state.copyWith(
        selectedAddressId: event.addressId,
        clearError: true,
      ),
    );
  }

  Future<void> _onConfirmBooking(
    ConfirmBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    final customer = state.customer;
    final stylistService = state.stylistService;
    final selectedAddressId = state.selectedAddressId?.trim() ?? '';

    if (customer == null || stylistService == null) {
      emit(state.failure('Booking details are still loading. Please try again.'));
      return;
    }

    if (selectedAddressId.isEmpty) {
      emit(state.failure('Please choose a booking address.'));
      return;
    }

    emit(state.creating());

    final request = CreateBookingRequestEntity(
      customerId: customer.id,
      stylistId: event.stylistId,
      scheduledAt: event.scheduledAt,
      addressId: selectedAddressId,
      notes: event.notes,
      items: [
        CreateBookingServiceItemEntity(
          serviceId: event.serviceId,
          stylistServiceId: stylistService.id,
          quantity: 1,
        ),
      ],
    );

    final result = await createBookingWithServices(request);
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

  Future<void> _onSelectDate(
    SelectDateEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(selectedDate: event.date));
  }

  Future<void> _onSelectTime(
    SelectTimeEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(selectedTime: event.time));
  }

  void _onClearBookingMessage(
    ClearBookingMessageEvent event,
    Emitter<BookingState> emit,
  ) {
    emit(state.copyWith(clearMessage: true, clearError: true));
  }

  Future<void> _onLoadBookingContext(
    LoadBookingContextEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.loading());

    final customerResult = await getCurrentCustomer();
    final stylistServicesResult = await getStylistServices(event.stylistId);

    // Handle failures
    if (customerResult.isLeft()) {
      return customerResult.fold(
        (failure) => emit(state.failure(failure.message)),
        (_) => null,
      );
    }

    if (stylistServicesResult.isLeft()) {
      return stylistServicesResult.fold(
        (failure) => emit(state.failure(failure.message)),
        (_) => null,
      );
    }

    final customer = customerResult.fold((l) => null, (r) => r)!;
    final stylistServices = stylistServicesResult.fold(
      (l) => <StylistsServiceEntity>[],
      (r) => r,
    );

    final matchingService = stylistServices
        .where((service) => service.isAvailable)
        .where((service) => service.serviceId == event.serviceId)
        .cast<StylistsServiceEntity?>()
        .firstWhere((service) => service != null, orElse: () => null);

    if (matchingService == null) {
      emit(state.failure('This stylist is not available for the selected service.'));
      return;
    }

    emit(
      state.copyWith(
        status: BookingBlocStatus.loaded,
        customer: customer,
        stylistService: matchingService,
        addresses: customer.addresses,
        selectedAddressId: customer.defaultAddress?.id,
        message: 'Booking context loaded.',
        clearError: true,
      ),
    );
  }

  List<CustomerAddressEntity> _mergeAddresses(
    List<CustomerAddressEntity> addresses,
    CustomerAddressEntity createdAddress,
  ) {
    final existingIndex = addresses.indexWhere(
      (address) => address.id == createdAddress.id,
    );

    if (existingIndex == -1) {
      return <CustomerAddressEntity>[...addresses, createdAddress];
    }

    final updated = <CustomerAddressEntity>[...addresses];
    updated[existingIndex] = createdAddress;
    return updated;
  }

  Future<List<BookingEntity>> _syncExpiredBookings(
    List<BookingEntity> bookings,
  ) async {
    final now = DateTime.now();
    final syncedBookings = <BookingEntity>[];

    for (final booking in bookings) {
      final shouldMarkPassed =
          booking.status == BookingStatus.pending && booking.endAt.isBefore(now);

      if (!shouldMarkPassed) {
        syncedBookings.add(booking);
        continue;
      }

      final result = await updateBookingStatus(
        booking.id,
        BookingStatus.passed.name,
      );

      result.fold(
        (_) => syncedBookings.add(
          BookingEntity(
            id: booking.id,
            customerId: booking.customerId,
            stylistId: booking.stylistId,
            serviceName: booking.serviceName,
            stylistName: booking.stylistName,
            status: BookingStatus.passed,
            notes: booking.notes,
            addressId: booking.addressId,
            totalAmount: booking.totalAmount,
            scheduledAt: booking.scheduledAt,
            endAt: booking.endAt,
            createdAt: booking.createdAt,
            updatedAt: DateTime.now(),
          ),
        ),
        (updatedBooking) => syncedBookings.add(updatedBooking),
      );
    }

    return syncedBookings;
  }

  List<BookingEntity> _mergeUpdatedBooking(
    List<BookingEntity> bookings,
    BookingEntity updatedBooking,
  ) {
    final bookingIndex = bookings.indexWhere(
      (booking) => booking.id == updatedBooking.id,
    );

    if (bookingIndex == -1) {
      return bookings;
    }

    final mergedBookings = <BookingEntity>[...bookings];
    mergedBookings[bookingIndex] = updatedBooking;
    return mergedBookings;
  }

  List<BookingEntity> _markBookingCancelled(
    List<BookingEntity> bookings,
    String bookingId,
  ) {
    return bookings
        .map(
          (booking) => booking.id != bookingId
              ? booking
              : BookingEntity(
                  id: booking.id,
                  customerId: booking.customerId,
                  stylistId: booking.stylistId,
                  serviceName: booking.serviceName,
                  stylistName: booking.stylistName,
                  status: BookingStatus.cancelled,
                  notes: booking.notes,
                  addressId: booking.addressId,
                  totalAmount: booking.totalAmount,
                  scheduledAt: booking.scheduledAt,
                  endAt: booking.endAt,
                  createdAt: booking.createdAt,
                  updatedAt: DateTime.now(),
                ),
        )
        .toList();
  }
}
