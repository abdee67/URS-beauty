import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/reviews/data/datasource/review_remote_data_source.dart';
import 'package:urs_beauty/features/reviews/data/model/review_model.dart';
import 'package:urs_beauty/features/reviews/domain/entity/review_entity.dart';
import 'package:urs_beauty/features/reviews/domain/repository/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  ReviewRepositoryImpl({required this.remoteDataSource});

  final ReviewRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failures, ReviewEntity>> submitReview(
    ReviewEntity review,
  ) async {
    return _runOperation(() async {
      _validateReview(review);
      final result = await remoteDataSource.submitReview(
        _mapReviewEntityToModel(review),
      );
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failures, ReviewEntity>> getReviewByBookingId(
    String bookingId,
  ) async {
    return _runOperation(() async {
      final result = await remoteDataSource.getReviewByBookingId(bookingId);
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failures, List<ReviewEntity>>> getReviewsByStylistId(
    String stylistId,
  ) async {
    return _runOperation(() async {
      final result = await remoteDataSource.getReviewsByStylistId(stylistId);
      return result.map((review) => review.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failures, List<ReviewEntity>>> getReviewsByCustomerId(
    String customerId,
  ) async {
    return _runOperation(() async {
      final result = await remoteDataSource.getReviewsByCustomerId(customerId
      );
      return result.map((review) => review.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failures, RatingSummary>> getRatingSummary(
    String stylistId,
  ) async {
    return _runOperation(() async {
      final result = await remoteDataSource.getRatingSummary(stylistId);
      return result.toSummary();
    });
  }

  Future<Either<Failures, T>> _runOperation<T>(
    Future<T> Function() operation,
  ) async {
    try {
      return Right(await operation());
    } on Failures catch (failure) {
      return Left(failure);
    } catch (error) {
      return Left(Failures(message: error.toString()));
    }
  }

  ReviewModel _mapReviewEntityToModel(ReviewEntity review) {
    return ReviewModel(
      id: review.id,
      customerId: review.customerId,
      stylistId: review.stylistId,
      bookingId: review.bookingId,
      rating: review.rating,
      comment: review.comment,
      createdAt: review.createdAt,
    );
  }

  void _validateReview(ReviewEntity review) {
    if (review.bookingId.isEmpty) {
      throw Failures(message: 'Booking ID is required');
    }

    if (review.rating < 1 || review.rating > 5) {
      throw Failures(message: 'Rating must be between 1 and 5');
    }
  }
}
