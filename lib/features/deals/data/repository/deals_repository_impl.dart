import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/deals/data/datasource/deals_remote_data_source.dart' show DealsRemoteDataSource;
import 'package:urs_beauty/features/deals/domain/entities/deal.dart';
import 'package:urs_beauty/features/deals/domain/repository/deals_repository.dart';

class DealsRepositoryImpl implements DealsRepository {

  final DealsRemoteDataSource remoteDataSource;

  DealsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failures, List<Deal>>> getDeals() async {
    try {
      final deals = await remoteDataSource.getDeals();
      return Right(deals.map((e) => e.toEntity()).toList());
    } on Failures catch (e) {
      return Left(e);
    }
  }}