import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/reviews/domain/entity/review_entity.dart';

typedef RatingSummary = ({double averageRating, int totalReviews});

abstract class ReviewRepository {
  Future<Either<Failures, ReviewEntity>> submitReview(ReviewEntity review);
  Future<Either<Failures, List<ReviewEntity>>> getReviewsByStylistId(
    String stylistId,
  );
  Future<Either<Failures, List<ReviewEntity>>> getReviewsByCustomerId(
    String customerId,
  );
  Future<Either<Failures, ReviewEntity?>> getReviewByBookingId(
    String bookingId,
  );
  Future<Either<Failures, RatingSummary>> getRatingSummary(String stylistId);
}
