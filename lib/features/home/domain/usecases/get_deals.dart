import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/home/domain/entities/deal.dart';
import 'package:urs_beauty/features/home/domain/repositories/home_repository.dart';

class GetDeals {
  final HomeRepository repository;

  GetDeals(this.repository);

  Future<Either<Failures, List<Deal>>> call() async {
    return await repository.getDeals();
  }
}