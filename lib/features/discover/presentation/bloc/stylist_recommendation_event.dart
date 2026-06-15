part of 'stylist_recommendation_bloc.dart';

abstract class StylistRecommendationEvent extends Equatable {
  const StylistRecommendationEvent();

  @override
  List<Object?> get props => [];
}

class SearchStylists extends StylistRecommendationEvent {
  const SearchStylists({
    required this.serviceId,
    required this.requestedDateTime,
  });

  final String serviceId;
  final DateTime requestedDateTime;

  @override
  List<Object?> get props => [serviceId, requestedDateTime];
}

class SortStylists extends StylistRecommendationEvent {
  const SortStylists(this.sortBy);

  final SortBy sortBy;

  @override
  List<Object?> get props => [sortBy];
}

class ToggleMapView extends StylistRecommendationEvent {
  const ToggleMapView();
}

class LoadMoreStylists extends StylistRecommendationEvent {
  const LoadMoreStylists();
}
