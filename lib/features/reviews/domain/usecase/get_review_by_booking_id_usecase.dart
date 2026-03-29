import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/reviews/domain/entity/review_entity.dart';
import 'package:urs_beauty/features/reviews/domain/repository/review_repository.dart';

class GetReviewByBookingIdUsecase {
  final ReviewRepository repository;

  GetReviewByBookingIdUsecase(this.repository);

  Future<Either<Failures, ReviewEntity>> call(String bookingId) {
    return repository.getReviewByBookingId(bookingId);
}
}