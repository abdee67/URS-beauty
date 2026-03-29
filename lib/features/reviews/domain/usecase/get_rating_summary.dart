import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/reviews/domain/repository/review_repository.dart';

class GetRatingSummary {
  final ReviewRepository repository;

  GetRatingSummary(this.repository);

  Future<Either<Failures, RatingSummary>> call(String stylistId) {
    return repository.getRatingSummary(stylistId);
}
}