import 'package:equatable/equatable.dart';
import 'package:urs_beauty/features/reviews/domain/entity/review_entity.dart';
import 'package:urs_beauty/features/reviews/domain/repository/review_repository.dart';

enum ReviewBlocStatus {
  initial,
  loading,
  loaded,
  submitting,
  submitted,
  ratingLoading,
  ratingLoaded,
  failure,
}

class ReviewState extends Equatable {
  const ReviewState({
    this.status = ReviewBlocStatus.initial,
    this.reviews = const [],
    this.stylistReviews = const [],
    this.customerReviews = const [],
    this.selectedReview,
    this.ratingSummary,
    this.message,
    this.errorMessage = '',
  });

  final ReviewBlocStatus status;
  final List<ReviewEntity> reviews;
  final List<ReviewEntity> stylistReviews;
  final List<ReviewEntity> customerReviews;
  final ReviewEntity? selectedReview;
  final RatingSummary? ratingSummary;
  final String? message;
  final String errorMessage;

  ReviewState loading([String? message]) => copyWith(
        status: ReviewBlocStatus.loading,
        message: message,
        clearError: true,
      );

  ReviewState submitting() =>
      copyWith(status: ReviewBlocStatus.submitting, clearError: true);

  ReviewState ratingLoading() =>
      copyWith(status: ReviewBlocStatus.ratingLoading, clearError: true);

  ReviewState failure(String message) =>
      copyWith(status: ReviewBlocStatus.failure, errorMessage: message);

  ReviewState copyWith({
    ReviewBlocStatus? status,
    List<ReviewEntity>? reviews,
    List<ReviewEntity>? stylistReviews,
    List<ReviewEntity>? customerReviews,
    ReviewEntity? selectedReview,
    RatingSummary? ratingSummary,
    String? message,
    String? errorMessage,
    bool clearSelectedReview = false,
    bool clearMessage = false,
    bool clearError = false,
  }) {
    return ReviewState(
      status: status ?? this.status,
      reviews: reviews ?? this.reviews,
      stylistReviews: stylistReviews ?? this.stylistReviews,
      customerReviews: customerReviews ?? this.customerReviews,
      selectedReview:
          clearSelectedReview ? null : (selectedReview ?? this.selectedReview),
      ratingSummary: ratingSummary ?? this.ratingSummary,
      message: clearMessage ? null : (message ?? this.message),
      errorMessage: clearError ? '' : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        reviews,
        stylistReviews,
        customerReviews,
        selectedReview,
        ratingSummary,
        message,
        errorMessage,
      ];
}