import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/discover/data/models/stylist_card_model.dart';
import 'package:urs_beauty/features/discover/domain/usecases/fetch_stylist_recommendations.dart';
import 'package:urs_beauty/features/discover/domain/usecases/get_client_location.dart';

part 'stylist_recommendation_event.dart';
part 'stylist_recommendation_state.dart';

class StylistRecommendationBloc
    extends Bloc<StylistRecommendationEvent, StylistRecommendationState> {
  StylistRecommendationBloc({
    required GetClientLocation getClientLocation,
    required FetchStylistRecommendations fetchStylistRecommendations,
  }) : _getClientLocation = getClientLocation,
       _fetchStylistRecommendations = fetchStylistRecommendations,
       super(const RecommendationInitial()) {
    on<SearchStylists>(_onSearch);
    on<SortStylists>(_onSort);
    on<ToggleMapView>(_onToggleMap);
    on<LoadMoreStylists>(_onLoadMore);
  }

  static const int _limit = 20;

  final GetClientLocation _getClientLocation;
  final FetchStylistRecommendations _fetchStylistRecommendations;

  String? _serviceId;
  DateTime? _requestedDateTime;
  double? _clientLat;
  double? _clientLng;
  bool _isLoadingMore = false;

  Future<void> _onSearch(
    SearchStylists event,
    Emitter<StylistRecommendationState> emit,
  ) async {
    emit(const RecommendationLoading());
    _serviceId = event.serviceId;
    _requestedDateTime = event.requestedDateTime;

    final locationResult = await _getClientLocation();
    Failures? locationFailure;
    Position? position;
    locationResult.fold(
      (failure) => locationFailure = failure,
      (clientPosition) => position = clientPosition,
    );

    if (locationFailure != null || position == null) {
      emit(_errorFromFailure(locationFailure));
      return;
    }

    _clientLat = position!.latitude;
    _clientLng = position!.longitude;

    final result = await _fetchStylistRecommendations(
      serviceId: event.serviceId,
      clientLat: position!.latitude,
      clientLng: position!.longitude,
      requestedDateTime: event.requestedDateTime,
      limit: _limit,
    );

    Failures? fetchFailure;
    List<StylistCardModel> stylists = const <StylistCardModel>[];
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
        RecommendationEmpty(
          serviceId: event.serviceId,
          requestedDateTime: event.requestedDateTime,
        ),
      );
      return;
    }

    emit(
      RecommendationLoaded(
        stylists: stylists,
        sortedStylists: _sortStylists(stylists, SortBy.distance),
        sortBy: SortBy.distance,
        hasMore: stylists.length == _limit,
      ),
    );
  }

  void _onSort(SortStylists event, Emitter<StylistRecommendationState> emit) {
    final current = state;
    if (current is! RecommendationLoaded) {
      return;
    }

    emit(
      current.copyWith(
        sortedStylists: _sortStylists(current.stylists, event.sortBy),
        sortBy: event.sortBy,
      ),
    );
  }

  void _onToggleMap(
    ToggleMapView event,
    Emitter<StylistRecommendationState> emit,
  ) {
    final current = state;
    if (current is! RecommendationLoaded) {
      return;
    }

    emit(current.copyWith(isMapView: !current.isMapView));
  }

  Future<void> _onLoadMore(
    LoadMoreStylists event,
    Emitter<StylistRecommendationState> emit,
  ) async {
    final current = state;
    final serviceId = _serviceId;
    final requestedDateTime = _requestedDateTime;
    final clientLat = _clientLat;
    final clientLng = _clientLng;

    if (current is! RecommendationLoaded ||
        !current.hasMore ||
        _isLoadingMore ||
        serviceId == null ||
        requestedDateTime == null ||
        clientLat == null ||
        clientLng == null) {
      return;
    }

    _isLoadingMore = true;
    final result = await _fetchStylistRecommendations(
      serviceId: serviceId,
      clientLat: clientLat,
      clientLng: clientLng,
      requestedDateTime: requestedDateTime,
      limit: _limit,
      offset: current.stylists.length,
    );
    _isLoadingMore = false;

    Failures? failure;
    List<StylistCardModel> nextPage = const <StylistCardModel>[];
    result.fold((error) => failure = error, (items) => nextPage = items);

    if (failure != null) {
      emit(_errorFromFailure(failure));
      return;
    }

    final merged = <StylistCardModel>[...current.stylists, ...nextPage];
    emit(
      current.copyWith(
        stylists: merged,
        sortedStylists: _sortStylists(merged, current.sortBy),
        hasMore: nextPage.length == _limit,
      ),
    );
  }

  List<StylistCardModel> _sortStylists(
    List<StylistCardModel> stylists,
    SortBy sortBy,
  ) {
    final sorted = List<StylistCardModel>.from(stylists);
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

  RecommendationError _errorFromFailure(Failures? failure) {
    final message = failure?.message.trim();
    return RecommendationError(
      message: message == null || message.isEmpty
          ? 'Something went wrong. Please try again.'
          : message,
      isLocationError: failure is LocationFailure,
    );
  }
}
