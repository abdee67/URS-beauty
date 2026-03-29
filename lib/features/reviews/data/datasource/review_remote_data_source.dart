import 'package:urs_beauty/features/reviews/data/dto/rating_summary_dto.dart';
import 'package:urs_beauty/features/reviews/data/model/review_model.dart';

abstract class ReviewRemoteDataSource {
  Future<ReviewModel> submitReview(ReviewModel review);
  Future<List<ReviewModel>> getReviewsByStylistId(String stylistId);
  Future<List<ReviewModel>> getReviewsByCustomerId(String customerId);
  Future<ReviewModel> getReviewByBookingId(String bookingId);
  Future<RatingSummaryDto> getRatingSummary(String stylistId);
}
