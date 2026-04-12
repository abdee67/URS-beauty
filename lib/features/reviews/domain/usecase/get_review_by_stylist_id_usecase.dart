import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/reviews/domain/entity/review_entity.dart';
import 'package:urs_beauty/features/reviews/domain/repository/review_repository.dart';

class GetReviewByStylistIdUsecase {
  final ReviewRepository repository;

  GetReviewByStylistIdUsecase(this.repository);

  Future<Either<Failures, List<ReviewEntity>>> call(String stylistId) {
    return repository.getReviewsByStylistId(stylistId);
}
}