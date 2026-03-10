import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/deals/domain/entities/deal.dart';
import 'package:urs_beauty/features/deals/domain/repository/deals_repository.dart';

class GetDeals {
  final DealsRepository repository;

  GetDeals(this.repository);

  Future<Either<Failures, List<Deal>>> call() async {
    return await repository.getDeals();
  }
}