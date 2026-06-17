import 'dart:developer' as developer;

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_availability_slot_entity.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylists_availability_entity.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_client_location.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_nearby_stylists.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_stylist_by_service.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_stylist_detail.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_stylist_recommendations.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_stylists.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_stylists_availability.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_stylists_availability_by_day.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_stylists_availability_by_time.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_stylists_service.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/search_stylists.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/update_stylists_availability.dart';

part 'stylists_event.dart';
part 'stylists_state.dart';

class StylistsBloc extends Bloc<StylistsEvent, StylistsState> {
  StylistsBloc(
    this.getStylistsAvailability,
    this.getStylistsAvailabilityByDay,
    this.getStylistsAvailabilityByTime,
    this.updateStylistsAvailability,
    this.getStylistsServices,
    this.getStylists,
    this.getStylistsByService,
    this.getStylistDetail,
    this.searchStylists,
    this.getNearByStylists,
    this.getClientLocation,
    this.getStylistRecommendations,
  ) : super(const StylistsState()) {
    on<GetStylistsEvent>(_onGetStylists);
    on<GetStylistsByServiceEvent>(_onGetStylistsByService);
    on<GetStylistDetailEvent>(_onGetStylistDetail);
    on<SearchStylistsEvent>(_onSearchStylists);
    on<GetStylistsServicesEvent>(_onGetStylistsServices);
    on<GetNearbyStylistsEvent>(_onGetNearbyStylists);
    on<UpdateStylistsAvailabilityEvent>(_onUpdateStylistsAvailability);
    on<GetStylistsAvailabilityEvent>(_onGetStylistsAvailability);
    on<GetStylistsAvailabilityByDayEvent>(_onGetStylistsAvailabilityByDay);
    on<GetStylistsAvailabilityByTimeEvent>(_onGetStylistsAvailabilityByTime);
    on<SearchStylistsForService>(_onSearchStylistsForService);
    on<SortStylists>(_onSort);
    on<ToggleMapView>(_onToggleMap);
    on<LoadMoreStylists>(_onLoadMore);
  }

  final GetStylistsAvailability getStylistsAvailability;
  final GetStylistsAvailabilityByDay getStylistsAvailabilityByDay;
  final GetStylistsAvailabilityByTime getStylistsAvailabilityByTime;
  final UpdateStylistsAvailability updateStylistsAvailability;
  final GetStylistsService getStylistsServices;
  final GetStylists getStylists;
  final GetStylistByService getStylistsByService;
  final GetStylistDetail getStylistDetail;
  final SearchStylists searchStylists;
  final GetNearbyStylists getNearByStylists;

  final GetClientLocation getClientLocation;
  final GetStylistRecommendations getStylistRecommendations;

  static const int _limit = 20;

  String? _serviceId;
  DateTime? _requestedDateTime;
  double? _clientLat;
  double? _clientLng;
  bool _isLoadingMore = false;

  Future<void> _onGetStylists(
    GetStylistsEvent event,
    Emitter<StylistsState> emit,
  ) async {
    emit(state.stylistsLoading());
    final result = await getStylists();
    result.fold(
      (failure) =>
          emit(state.stylistsError("Can't get stylists: ${failure.message}")),
      (stylists) => emit(
        state.copyWith(
          stylists: stylists,
          status: StylistsStatus.stylisstsLoaded,
        ),
      ),
    );
  }

  Future<void> _onGetStylistsByService(
    GetStylistsByServiceEvent event,
    Emitter<StylistsState> emit,
  ) async {
    emit(state.stylistsByServiceLoading());
    final result = await getStylistsByService(event.serviceId);
    result.fold(
      (failure) => emit(
        state.stylistsError(
          "Can't get stylists by service: ${failure.message}",
        ),
      ),
      (stylists) => emit(
        state.copyWith(
          stylistsByService: stylists,
          status: StylistsStatus.stylistsByServiceLoaded,
        ),
      ),
    );
  }

  Future<void> _onGetStylistDetail(
    GetStylistDetailEvent event,
    Emitter<StylistsState> emit,
  ) async {
    emit(state.stylistDetailLoading());
    final result = await getStylistDetail(event.stylistId);
    result.fold(
      (failure) => emit(
        state.stylistsError("Can't get stylist detail: ${failure.message}"),
      ),
      (stylist) => emit(
        state.copyWith(
          stylistDetail: stylist,
          status: StylistsStatus.stylistDetailLoaded,
        ),
      ),
    );
  }

  Future<void> _onSearchStylists(
    SearchStylistsEvent event,
    Emitter<StylistsState> emit,
  ) async {
    emit(state.stylistSearching());
    final result = await searchStylists(event.query);
    result.fold(
      (failure) => emit(
        state.stylistsError("Can't get searched stylists: ${failure.message}"),
      ),
      (stylists) => emit(
        state.copyWith(
          searchedStylists: stylists,
          status: StylistsStatus.success,
        ),
      ),
    );
  }

  Future<void> _onGetStylistsServices(
    GetStylistsServicesEvent event,
    Emitter<StylistsState> emit,
  ) async {
    emit(state.stylistsServiceLoading());
    final result = await getStylistsServices(event.stylistId);
    result.fold(
      (failure) => emit(
        state.stylistsError("Can't get stylist services: ${failure.message}"),
      ),
      (services) => emit(
        state.copyWith(
          stylsitService: services,
          status: StylistsStatus.stylistsServiceLoaded,
        ),
      ),
    );
  }

  Future<void> _onGetNearbyStylists(
    GetNearbyStylistsEvent event,
    Emitter<StylistsState> emit,
  ) async {
    emit(state.nearbyStylistsLoading());
    final result = await getNearByStylists(
      event.latitude,
      event.longitude,
      event.radius,
    );
    result.fold(
      (failure) => emit(
        state.stylistsError("Can't get nearby stylists: ${failure.message}"),
      ),
      (stylists) => emit(
        state.copyWith(
          nearbyStylists: stylists,
          status: StylistsStatus.nearbyStylistsLoaded,
        ),
      ),
    );
  }

  Future<void> _onUpdateStylistsAvailability(
    UpdateStylistsAvailabilityEvent event,
    Emitter<StylistsState> emit,
  ) async {
    emit(state.updateStylistsAvailabilityLoading());
    final result = await updateStylistsAvailability(event.availability);
    result.fold(
      (failure) => emit(
        state.stylistsError(
          "Can't update stylist availability: ${failure.message}",
        ),
      ),
      (_) => emit(
        state.copyWith(
          message: 'Stylists availability updated successfully',
          status: StylistsStatus.updateStylistsAvailabilityLoaded,
        ),
      ),
    );
  }

  Future<void> _onGetStylistsAvailability(
    GetStylistsAvailabilityEvent event,
    Emitter<StylistsState> emit,
  ) async {
    emit(state.stylistsAvailabilityLoading());
    final result = await getStylistsAvailability(event.stylistId);
    result.fold(
      (failure) => emit(
        state.stylistsError(
          "Can't get stylist availability: ${failure.message}",
        ),
      ),
      (availability) => emit(
        state.copyWith(
          stylistsAvailability: availability,
          status: StylistsStatus.stylistsAvailabilityLoaded,
        ),
      ),
    );
  }

  Future<void> _onGetStylistsAvailabilityByDay(
    GetStylistsAvailabilityByDayEvent event,
    Emitter<StylistsState> emit,
  ) async {
    emit(state.stylistsAvailabilityByDayLoading());
    final result = await getStylistsAvailabilityByDay(
      event.stylistId,
      event.dayOfWeek,
    );
    result.fold(
      (failure) => emit(
        state.stylistsError(
          "Can't get stylist availability by day: ${failure.message}",
        ),
      ),
      (availability) => emit(
        state.copyWith(
          stylistsAvailabilityByDay: availability,
          status: StylistsStatus.stylistsAvailabilityByDayLoaded,
        ),
      ),
    );
  }

  Future<void> _onGetStylistsAvailabilityByTime(
    GetStylistsAvailabilityByTimeEvent event,
    Emitter<StylistsState> emit,
  ) async {
    emit(state.stylistsAvailabilityByTimeLoading());
    final result = await getStylistsAvailabilityByTime(
      event.stylistId,
      event.serviceId,
      event.selectedDate,
      ignoredBookingId: event.ignoredBookingId,
    );
    result.fold(
      (failure) => emit(
        state.stylistsError(
          "Can't get stylist availability by time: ${failure.message}",
        ),
      ),

      (availability) => emit(
        state.copyWith(
          stylistsAvailabilityByTime: availability,
          status: StylistsStatus.stylistsAvailabilityByTimeLoaded,
        ),
      ),
    );
  }

  Future<void> _onSearchStylistsForService(
    SearchStylistsForService event,
    Emitter<StylistsState> emit,
  ) async {
    emit(state.recommenedStylistsLoading());
    _serviceId = event.serviceId;
    _requestedDateTime = event.requestedDateTime;

    final locationResult = await getClientLocation();
    Failures? locationFailure;
    Position? position;
    locationResult.fold(
      (failure) => locationFailure = failure,
      (clientPosition) => position = clientPosition,
    );

    if (locationFailure != null || position == null) {
      emit(
        state.recommenedStylistsError(
          "Can't get stylist recommendations: ${locationFailure?.message}",
        ),
      );
      return;
    }

    _clientLat = position!.latitude;
    _clientLng = position!.longitude;

    final result = await getStylistRecommendations(
      serviceId: event.serviceId,
      clientLat: position!.latitude,
      clientLng: position!.longitude,
      requestedDateTime: event.requestedDateTime,
      limit: _limit,
    );

    Failures? fetchFailure;
    List<Stylist> stylists = const <Stylist>[];
    result.fold(
      (failure) => fetchFailure = failure,
      (items) => stylists = items,
    );

    if (fetchFailure != null) {
      emit(_errorFromFailure(fetchFailure));
      return;
    }

    if (stylists.isEmpty) {
      emit(
        state.recommenedStylistsEmpty(
          serviceId: event.serviceId,
          requestedDateTime: event.requestedDateTime,
        ),
      );
      return;
    }
    if (kDebugMode) {
      developer.log('recomended stylists: ${stylists.length}');
    }

    emit(
      state.recommenedStylistsLoaded(
        stylists: stylists,
        sortedStylists: _sortStylists(stylists, SortBy.distance),
        sortBy: SortBy.distance,
        hasMore: stylists.length == _limit,
      ),
    );
    if (kDebugMode) {
      developer.log('recomended stylists: ${stylists.length}');
    }
  }

  void _onSort(SortStylists event, Emitter<StylistsState> emit) {
    final current = state;
    if (current.status != StylistsStatus.recomendedStylistsLoaded) {
      return;
    }

    emit(
      current.copyWith(
        sortedStylists: _sortStylists(
          current.stylists.cast<Stylist>(),
          event.sortBy,
        ),
        sortBy: event.sortBy,
      ),
    );
  }

  void _onToggleMap(ToggleMapView event, Emitter<StylistsState> emit) {
    final current = state;
    if (current.status != StylistsStatus.recomendedStylistsLoaded) {
      return;
    }

    emit(current.copyWith(isMapView: !current.isMapView));
  }

  Future<void> _onLoadMore(
    LoadMoreStylists event,
    Emitter<StylistsState> emit,
  ) async {
    final current = state;
    final serviceId = _serviceId;
    final requestedDateTime = _requestedDateTime;
    final clientLat = _clientLat;
    final clientLng = _clientLng;

    if (current.status != StylistsStatus.recomendedStylistsLoaded ||
        !current.hasMore ||
        _isLoadingMore ||
        serviceId == null ||
        requestedDateTime == null ||
        clientLat == null ||
        clientLng == null) {
      return;
    }

    _isLoadingMore = true;
    final result = await getStylistRecommendations(
      serviceId: serviceId,
      clientLat: clientLat,
      clientLng: clientLng,
      requestedDateTime: requestedDateTime,
      limit: _limit,
      offset: current.stylists.length,
    );
    _isLoadingMore = false;

    Failures? failure;
    List<Stylist> nextPage = const <Stylist>[];
    result.fold((error) => failure = error, (items) => nextPage = items);

    if (failure != null) {
      emit(_errorFromFailure(failure));
      return;
    }

    final merged = <Stylist>[...current.stylists.cast<Stylist>(), ...nextPage];
    emit(
      current.copyWith(
        stylists: merged,
        sortedStylists: _sortStylists(merged, current.sortBy),
        hasMore: nextPage.length == _limit,
      ),
    );
  }

  List<Stylist> _sortStylists(List<Stylist> stylists, SortBy sortBy) {
    final sorted = List<Stylist>.from(stylists);
    sorted.sort((a, b) {
      switch (sortBy) {
        case SortBy.distance:
          return a.distanceKm.compareTo(b.distanceKm);
        case SortBy.rating:
          return b.averageRating.compareTo(a.averageRating);
        case SortBy.price:
          return a.servicePrice.compareTo(b.servicePrice);
      }
    });
    return sorted;
  }

  StylistsState _errorFromFailure(Failures? failure) {
    final message = failure?.message.trim();
    return state.copyWith(
      status: StylistsStatus.recomendedStylistsError,
      errorMessage: message == null || message.isEmpty
          ? 'Something went wrong. Please try again.'
          : message,
      isLocationError: failure is LocationFailure,
    );
  }
}
