part of 'review_bloc.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object?> get props => [];
}

class SubmitReviewEvent extends ReviewEvent {
  const SubmitReviewEvent(this.review);

  final ReviewEntity review;

  @override
  List<Object?> get props => [review];
}

class GetReviewsByStylistIdEvent extends ReviewEvent {
  const GetReviewsByStylistIdEvent(this.stylistId);

  final String stylistId;

  @override
  List<Object?> get props => [stylistId];
}

class GetReviewsByCustomerIdEvent extends ReviewEvent {
  const GetReviewsByCustomerIdEvent(this.customerId);

  final String customerId;

  @override
  List<Object?> get props => [customerId];
}

class GetReviewByBookingIdEvent extends ReviewEvent {
  const GetReviewByBookingIdEvent(this.bookingId);

  final String bookingId;

  @override
  List<Object?> get props => [bookingId];
}

class GetRatingSummaryEvent extends ReviewEvent {
  const GetRatingSummaryEvent(this.stylistId);

  final String stylistId;

  @override
  List<Object?> get props => [stylistId];
}

class ClearReviewMessageEvent extends ReviewEvent {
  const ClearReviewMessageEvent();
}
