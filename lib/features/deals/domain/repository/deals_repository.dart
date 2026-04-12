  
  import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/deals/domain/entities/deal.dart';

abstract class DealsRepository {
  Future<Either<Failures, List<Deal>>> getDeals();
}