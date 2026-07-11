part of 'stylists_bloc.dart';

enum StylistsStatus {
  initial,
  stylistsLoading,
  stylisstsLoaded,
  stylistsError,
  stylistDetailLoading,
  stylistDetailLoaded,
  stylistDetailError,
  stylistsByServiceLoading,
  stylistsByServiceLoaded,
  stylistsByServiceError,
  nearbyStylistsLoading,
  nearbyStylistsLoaded,
  nearbyStylistsError,
  stylistsAvailabilityLoading,
  stylistsAvailabilityLoaded,
  stylistsAvailabilityError,
  stylistsAvailabilityByDayLoading,
  stylistsAvailabilityByDayLoaded,
  stylistsAvailabilityByDayError,
  stylistsAvailabilityByTimeLoading,
  stylistsAvailabilityByTimeLoaded,
  stylistsAvailabilityByTimeError,
  updateStylistsAvailabilityLoading,
  updateStylistsAvailabilityLoaded,
  updateStylistsAvailabilityError,
  stylistsServiceLoading,
  stylistsServiceLoaded,
  stylistsServiceError,
  stylistSearching,
  recomendedStylistsInitial,
  recomendedStylistsLoading,
  recomendedStylistsLoaded,
  recomendedStylistsError,
  recomendedStylistsEmpty,
  success,
  failure,
}

enum SortBy { distance, rating, price }

class StylistsState extends Equatable {
  const StylistsState({
    this.status = StylistsStatus.initial,
    this.stylists = const [],
    this.stylistDetail,
    this.searchedStylists = const [],
    this.stylistsByService = const [],
    this.nearbyStylists = const [],
    this.stylistsAvailability = const [],
    this.stylistsAvailabilityByDay = const [],
    this.stylistsAvailabilityByTime = const [],
    this.updatedStylistsAvailability = const [],
    this.stylsitService = const [],
    this.message,
    this.errorMessage = '',
    this.query,
    this.sortedStylists = const [],
    this.sortBy = SortBy.distance,
    this.isMapView = false,
    this.hasMore = true,
    this.serviceId = '',
    this.requestedDateTime,
    this.isLocationError = false,
  });

  final StylistsStatus status;
  final List<Stylist> stylists;
  final Stylist? stylistDetail;
  final List<Stylist> searchedStylists;
  final List<Stylist> stylistsByService;
  final List<Stylist> nearbyStylists;
  final List<StylistsAvailability> stylistsAvailability;
  final List<StylistsAvailability> stylistsAvailabilityByDay;
  final List<StylistAvailabilitySlotEntity> stylistsAvailabilityByTime;
  final List<StylistsAvailability> updatedStylistsAvailability;
  final List<Stylist> stylsitService;
  final String? message;
  final String errorMessage;
  final String? query;
  final List<Stylist> sortedStylists;
  final SortBy sortBy;
  final bool isMapView;
  final bool hasMore;
  final String serviceId;
  final DateTime? requestedDateTime;
  final bool isLocationError;

  StylistsState stylistsLoading() =>
      copyWith(status: StylistsStatus.stylistsLoading);

  StylistsState stylistsLoaded() =>
      copyWith(status: StylistsStatus.stylisstsLoaded);

  StylistsState stylistsError(String message) =>
      copyWith(status: StylistsStatus.stylistsError, errorMessage: message);

  StylistsState stylistDetailLoading() =>
      copyWith(status: StylistsStatus.stylistDetailLoading);

  StylistsState stylistDetailLoaded() =>
      copyWith(status: StylistsStatus.stylistDetailLoaded);

  StylistsState stylistDetailError(String message) => copyWith(
    status: StylistsStatus.stylistDetailError,
    errorMessage: message,
  );

  StylistsState stylistsByServiceLoading() =>
      copyWith(status: StylistsStatus.stylistsByServiceLoading);

  StylistsState stylistsByServiceLoaded() =>
      copyWith(status: StylistsStatus.stylistsByServiceLoaded);

  StylistsState stylistsByServiceError(String message) => copyWith(
    status: StylistsStatus.stylistsByServiceError,
    errorMessage: message,
  );

  StylistsState nearbyStylistsLoading() =>
      copyWith(status: StylistsStatus.nearbyStylistsLoading);

  StylistsState nearbyStylistsLoaded() =>
      copyWith(status: StylistsStatus.nearbyStylistsLoaded);

  StylistsState nearbyStylistsError(String message) => copyWith(
    status: StylistsStatus.nearbyStylistsError,
    errorMessage: message,
  );

  StylistsState stylistsAvailabilityLoading() =>
      copyWith(status: StylistsStatus.stylistsAvailabilityLoading);

  StylistsState stylistsAvailabilityLoaded() =>
      copyWith(status: StylistsStatus.stylistsAvailabilityLoaded);

  StylistsState stylistsAvailabilityError(String message) => copyWith(
    status: StylistsStatus.stylistsAvailabilityError,
    errorMessage: message,
  );

  StylistsState stylistsAvailabilityByDayLoading() =>
      copyWith(status: StylistsStatus.stylistsAvailabilityByDayLoading);

  StylistsState stylistsAvailabilityByDayLoaded() =>
      copyWith(status: StylistsStatus.stylistsAvailabilityByDayLoaded);

  StylistsState stylistsAvailabilityByDayError(String message) => copyWith(
    status: StylistsStatus.stylistsAvailabilityByDayError,
    errorMessage: message,
  );

  StylistsState stylistsAvailabilityByTimeLoading() => copyWith(
    status: StylistsStatus.stylistsAvailabilityByTimeLoading,
    stylistsAvailabilityByTime: const [],
  );

  StylistsState stylistsAvailabilityByTimeLoaded() =>
      copyWith(status: StylistsStatus.stylistsAvailabilityByTimeLoaded);

  StylistsState stylistsAvailabilityByTimeError(String message) => copyWith(
    status: StylistsStatus.stylistsAvailabilityByTimeError,
    errorMessage: message,
  );

  StylistsState updateStylistsAvailabilityLoading() =>
      copyWith(status: StylistsStatus.updateStylistsAvailabilityLoading);

  StylistsState updateStylistsAvailabilityLoaded() =>
      copyWith(status: StylistsStatus.updateStylistsAvailabilityLoaded);

  StylistsState updateStylistsAvailabilityError(String message) => copyWith(
    status: StylistsStatus.updateStylistsAvailabilityError,
    errorMessage: message,
  );

  StylistsState stylistsServiceLoading() =>
      copyWith(status: StylistsStatus.stylistsServiceLoading);

  StylistsState stylistsServiceLoaded() =>
      copyWith(status: StylistsStatus.stylistsServiceLoaded);

  StylistsState stylistsServiceError(String message) => copyWith(
    status: StylistsStatus.stylistsServiceError,
    errorMessage: message,
  );

  StylistsState stylistSearching() =>
      copyWith(status: StylistsStatus.stylistSearching);

  StylistsState recomendedStylistsInitial() =>
      copyWith(status: StylistsStatus.recomendedStylistsInitial);

  StylistsState recommenedStylistsLoading() =>
      copyWith(status: StylistsStatus.recomendedStylistsLoading);

  StylistsState recommenedStylistsLoaded({
    List<Stylist>? stylists,
    List<Stylist>? sortedStylists,
    SortBy? sortBy,
    DateTime? requestedDateTime,
    bool? hasMore,
  }) => copyWith(
    status: StylistsStatus.recomendedStylistsLoaded,
    stylists: stylists,
    sortedStylists: sortedStylists,
    sortBy: sortBy,
    requestedDateTime: requestedDateTime,
    hasMore: hasMore,
  );

  StylistsState recommenedStylistsError(String message) => copyWith(
    status: StylistsStatus.recomendedStylistsError,
    errorMessage: message,
  );

  StylistsState recommenedStylistsEmpty({
    String? serviceId,
    DateTime? requestedDateTime,
  }) => copyWith(
    status: StylistsStatus.recomendedStylistsEmpty,
    serviceId: serviceId,
    requestedDateTime: requestedDateTime,
  );

  StylistsState success() => copyWith(status: StylistsStatus.success);

  StylistsState failure(String message) =>
      copyWith(status: StylistsStatus.failure, errorMessage: message);

  StylistsState copyWith({
    StylistsStatus? status,
    List<Stylist>? stylists,
    Stylist? stylistDetail,
    List<Stylist>? searchedStylists,
    List<Stylist>? stylistsByService,
    List<Stylist>? nearbyStylists,
    List<StylistsAvailability>? stylistsAvailability,
    List<StylistsAvailability>? stylistsAvailabilityByDay,
    List<StylistAvailabilitySlotEntity>? stylistsAvailabilityByTime,
    List<StylistsAvailability>? updatedStylistsAvailability,
    List<Stylist>? stylsitService,
    String? message,
    String? errorMessage,
    String? query,
    String? serviceId,
    DateTime? requestedDateTime,
    bool? isLocationError,
    bool? hasMore,
    bool? isMapView,
    SortBy? sortBy,
    List<Stylist>? sortedStylists,
  }) {
    return StylistsState(
      status: status ?? this.status,
      stylists: stylists ?? this.stylists,
      stylistDetail: stylistDetail ?? this.stylistDetail,
      searchedStylists: searchedStylists ?? this.searchedStylists,
      stylistsByService: stylistsByService ?? this.stylistsByService,
      nearbyStylists: nearbyStylists ?? this.nearbyStylists,
      stylistsAvailability: stylistsAvailability ?? this.stylistsAvailability,
      stylistsAvailabilityByDay:
          stylistsAvailabilityByDay ?? this.stylistsAvailabilityByDay,
      stylistsAvailabilityByTime:
          stylistsAvailabilityByTime ?? this.stylistsAvailabilityByTime,
      updatedStylistsAvailability:
          updatedStylistsAvailability ?? this.updatedStylistsAvailability,
      stylsitService: stylsitService ?? this.stylsitService,
      message: message ?? this.message,
      errorMessage: errorMessage ?? this.errorMessage,
      query: query ?? this.query,
      serviceId: serviceId ?? this.serviceId,
      requestedDateTime: requestedDateTime ?? this.requestedDateTime,
      isLocationError: isLocationError ?? this.isLocationError,
      hasMore: hasMore ?? this.hasMore,
      isMapView: isMapView ?? this.isMapView,
      sortBy: sortBy ?? this.sortBy,
      sortedStylists: sortedStylists ?? this.sortedStylists,
    );
  }

  @override
  List<Object?> get props => [
    status,
    stylists,
    stylistDetail,
    searchedStylists,
    stylistsByService,
    nearbyStylists,
    stylistsAvailability,
    stylistsAvailabilityByDay,
    stylistsAvailabilityByTime,
    updatedStylistsAvailability,
    stylsitService,
    message,
    errorMessage,
    query,
  ];
}
