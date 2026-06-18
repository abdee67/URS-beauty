part of 'stylist_recommendation_bloc.dart';

enum SortBy { distance, rating, price }

abstract class StylistRecommendationState extends Equatable {
  const StylistRecommendationState();

  @override
  List<Object?> get props => [];
}

class RecommendationInitial extends StylistRecommendationState {
  const RecommendationInitial();
}

class RecommendationLoading extends StylistRecommendationState {
  const RecommendationLoading();
}

class RecommendationLoaded extends StylistRecommendationState {
  const RecommendationLoaded({
    required this.stylists,
    required this.sortedStylists,
    required this.sortBy,
    this.isMapView = false,
    this.hasMore = true,
  });

  final List<StylistCardModel> stylists;
  final List<StylistCardModel> sortedStylists;
  final SortBy sortBy;
  final bool isMapView;
  final bool hasMore;

  RecommendationLoaded copyWith({
    List<StylistCardModel>? stylists,
    List<StylistCardModel>? sortedStylists,
    SortBy? sortBy,
    bool? isMapView,
    bool? hasMore,
  }) {
    return RecommendationLoaded(
      stylists: stylists ?? this.stylists,
      sortedStylists: sortedStylists ?? this.sortedStylists,
      sortBy: sortBy ?? this.sortBy,
      isMapView: isMapView ?? this.isMapView,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [
    stylists,
    sortedStylists,
    sortBy,
    isMapView,
    hasMore,
  ];
}

class RecommendationEmpty extends StylistRecommendationState {
  const RecommendationEmpty({
    required this.serviceId,
    required this.requestedDateTime,
  });

  final String serviceId;
  final DateTime requestedDateTime;

  @override
  List<Object?> get props => [serviceId, requestedDateTime];
}

class RecommendationError extends StylistRecommendationState {
  const RecommendationError({
    required this.message,
    this.isLocationError = false,
  });

  final String message;
  final bool isLocationError;

  @override
  List<Object?> get props => [message, isLocationError];
}
