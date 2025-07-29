import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/home/domain/entities/deal.dart';
import 'package:urs_beauty/features/home/domain/entities/professioanls.dart';
import 'package:urs_beauty/features/home/domain/entities/services.dart';

abstract class HomeRepository {
  Future<Either<Failures, List<Professionals>>> getProfessionals();
  Future<Either<Failures, List<Deal>>> getDeals();
  Future<Either<Failures, List<Services>>> getServices();
}