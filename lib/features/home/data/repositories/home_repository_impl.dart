import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/home/data/dataSources/home_remote_data_source.dart';
import 'package:urs_beauty/features/deals/domain/entities/deal.dart';
import 'package:urs_beauty/features/professionals/domain/entities/professioanls.dart';
import 'package:urs_beauty/features/beauty_services/domain/entities/service_category_entity.dart';
import 'package:urs_beauty/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failures, List<Professionals>>> getProfessionals() async {
    try {
      final profs = await remoteDataSource.getProfessionals();
      return Right(profs.map((e) => e.toEntity()).toList());
    } on Failures catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failures, List<Deal>>> getDeals() async {
    try {
      final deals = await remoteDataSource.getDeals();
      return Right(deals.map((e) => e.toEntity()).toList());
    } on Failures catch (e) {
      return Left(e);
    }
  }


}
