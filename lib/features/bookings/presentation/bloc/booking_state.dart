part of 'booking_bloc.dart';

enum BookingBlocStatus {
  initial,
  loading,
  loaded,
  creating,
  created,
  updating,
  updated,
  cancelling,
  cancelled,
  servicesLoading,
  servicesLoaded,
  searching,
  searched,
  failure,
}

class BookingState extends Equatable {
  const BookingState({
    this.status = BookingBlocStatus.initial,
    this.bookings = const [],
    this.customerBookings = const [],
    this.stylistBookings = const [],
    this.statusBookings = const [],
    this.searchedBookings = const [],
    this.bookingServices = const [],
    this.selectedBooking,
    this.message,
    this.errorMessage = '',
    this.query,
  });

  final BookingBlocStatus status;
  final List<BookingEntity> bookings;
  final List<BookingEntity> customerBookings;
  final List<BookingEntity> stylistBookings;
  final List<BookingEntity> statusBookings;
  final List<BookingEntity> searchedBookings;
  final List<BookingServicesEntity> bookingServices;
  final BookingEntity? selectedBooking;
  final String? message;
  final String errorMessage;
  final String? query;

  BookingState loading([String? message]) => copyWith(
    status: BookingBlocStatus.loading,
    message: message,
    clearError: true,
  );

  BookingState creating() =>
      copyWith(status: BookingBlocStatus.creating, clearError: true);

  BookingState updating() =>
      copyWith(status: BookingBlocStatus.updating, clearError: true);

  BookingState cancelling() =>
      copyWith(status: BookingBlocStatus.cancelling, clearError: true);

  BookingState servicesLoading() =>
      copyWith(status: BookingBlocStatus.servicesLoading, clearError: true);

  BookingState searching(String query) => copyWith(
    status: BookingBlocStatus.searching,
    query: query,
    clearError: true,
  );

  BookingState failure(String message) =>
      copyWith(status: BookingBlocStatus.failure, errorMessage: message);

  BookingState copyWith({
    BookingBlocStatus? status,
    List<BookingEntity>? bookings,
    List<BookingEntity>? customerBookings,
    List<BookingEntity>? stylistBookings,
    List<BookingEntity>? statusBookings,
    List<BookingEntity>? searchedBookings,
    List<BookingServicesEntity>? bookingServices,
    BookingEntity? selectedBooking,
    String? message,
    String? errorMessage,
    String? query,
    bool clearSelectedBooking = false,
    bool clearMessage = false,
    bool clearError = false,
    bool clearQuery = false,
  }) {
    return BookingState(
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
      customerBookings: customerBookings ?? this.customerBookings,
      stylistBookings: stylistBookings ?? this.stylistBookings,
      statusBookings: statusBookings ?? this.statusBookings,
      searchedBookings: searchedBookings ?? this.searchedBookings,
      bookingServices: bookingServices ?? this.bookingServices,
      selectedBooking: clearSelectedBooking
          ? null
          : (selectedBooking ?? this.selectedBooking),
      message: clearMessage ? null : (message ?? this.message),
      errorMessage: clearError ? '' : (errorMessage ?? this.errorMessage),
      query: clearQuery ? null : (query ?? this.query),
    );
  }

  @override
  List<Object?> get props => [
    status,
    bookings,
    customerBookings,
    stylistBookings,
    statusBookings,
    searchedBookings,
    bookingServices,
    selectedBooking,
    message,
    errorMessage,
    query,
  ];
}
