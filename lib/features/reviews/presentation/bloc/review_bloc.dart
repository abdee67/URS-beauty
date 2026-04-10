import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/features/reviews/domain/entity/review_entity.dart';
import 'package:urs_beauty/features/reviews/domain/usecase/get_review_by_booking_id_usecase.dart';
import 'package:urs_beauty/features/reviews/domain/usecase/get_review_by_cutomer_id_usecase.dart';
import 'package:urs_beauty/features/reviews/domain/usecase/get_review_by_stylist_id_usecase.dart';
import 'package:urs_beauty/features/reviews/domain/usecase/get_rating_summary.dart';
import 'package:urs_beauty/features/reviews/domain/usecase/submit_review_usecase.dart';
import 'package:urs_beauty/features/reviews/presentation/bloc/review_state.dart';

part 'review_event.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  ReviewBloc({
    required this.submitReview,
    required this.getReviewsByStylistId,
    required this.getReviewsByCustomerId,
    required this.getReviewByBookingId,
    required this.getRatingSummary,
  }) : super(const ReviewState()) {
    on<SubmitReviewEvent>(_onSubmitReview);
    on<GetReviewsByStylistIdEvent>(_onGetReviewsByStylistId);
    on<GetReviewsByCustomerIdEvent>(_onGetReviewsByCustomerId);
    on<GetReviewByBookingIdEvent>(_onGetReviewByBookingId);
    on<GetRatingSummaryEvent>(_onGetRatingSummary);
    on<ClearReviewMessageEvent>(_onClearReviewMessage);
  }

  final SubmitReviewUsecase submitReview;
  final GetReviewByStylistIdUsecase getReviewsByStylistId;
  final GetReviewByCutomerIdUsecase getReviewsByCustomerId;
  final GetReviewByBookingIdUsecase getReviewByBookingId;
  final GetRatingSummary getRatingSummary;

  Future<void> _onSubmitReview(
    SubmitReviewEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(state.submitting());

    final result = await submitReview(event.review);
    result.fold(
      (failure) => emit(state.failure(failure.message)),
      (review) {
        final updatedCustomerReviews = _upsertReview(state.customerReviews, review);
        final updatedStylistReviews = _upsertReview(state.stylistReviews, review);
        final ratingSummary = _buildRatingSummary(updatedStylistReviews);

        emit(
          state.copyWith(
            status: ReviewBlocStatus.submitted,
            selectedReview: review,
            customerReviews: updatedCustomerReviews,
            stylistReviews: updatedStylistReviews,
            ratingSummary: ratingSummary,
            message: 'Review submitted successfully.',
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> _onGetReviewsByStylistId(
    GetReviewsByStylistIdEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(state.loading());

    final result = await getReviewsByStylistId(event.stylistId);
    result.fold(
      (failure) => emit(state.failure(failure.message)),
      (reviews) => emit(
        state.copyWith(
          status: ReviewBlocStatus.loaded,
          stylistReviews: reviews,
          message: 'Stylist reviews loaded successfully.',
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onGetReviewsByCustomerId(
    GetReviewsByCustomerIdEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(state.loading());

    final result = await getReviewsByCustomerId(event.customerId);
    result.fold(
      (failure) => emit(state.failure(failure.message)),
      (reviews) => emit(
        state.copyWith(
          status: ReviewBlocStatus.loaded,
          customerReviews: reviews,
          message: 'Customer reviews loaded successfully.',
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onGetReviewByBookingId(
    GetReviewByBookingIdEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(state.loading());

    final result = await getReviewByBookingId(event.bookingId);
    result.fold(
      (failure) => emit(state.failure(failure.message)),
      (review) => emit(
        state.copyWith(
          status: ReviewBlocStatus.loaded,
          selectedReview: review,
          clearSelectedReview: review == null,
          message: 'Review loaded successfully.',
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onGetRatingSummary(
    GetRatingSummaryEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(state.ratingLoading());

    final result = await getRatingSummary(event.stylistId);
    result.fold(
      (failure) => emit(state.failure(failure.message)),
      (ratingSummary) => emit(
        state.copyWith(
          status: ReviewBlocStatus.ratingLoaded,
          ratingSummary: ratingSummary,
          message: 'Rating summary loaded successfully.',
          clearError: true,
        ),
      ),
    );
  }

  void _onClearReviewMessage(
    ClearReviewMessageEvent event,
    Emitter<ReviewState> emit,
  ) {
    emit(state.copyWith(clearMessage: true, clearError: true));
  }

  List<ReviewEntity> _upsertReview(List<ReviewEntity> reviews, ReviewEntity review) {
    final existingIndex = reviews.indexWhere(
      (item) => item.bookingId == review.bookingId,
    );

    if (existingIndex == -1) {
      return <ReviewEntity>[review, ...reviews];
    }

    final updatedReviews = <ReviewEntity>[...reviews];
    updatedReviews[existingIndex] = review;
    return updatedReviews;
  }

  ({double averageRating, int totalReviews})? _buildRatingSummary(
    List<ReviewEntity> reviews,
  ) {
    if (reviews.isEmpty) {
      return null;
    }

    final totalReviews = reviews.length;
    final averageRating =
        reviews.map((review) => review.rating).reduce((a, b) => a + b) /
            totalReviews;

    return (
      averageRating: averageRating,
      totalReviews: totalReviews,
    );
  }
}
