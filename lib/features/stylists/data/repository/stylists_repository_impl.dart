  import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/stylists/data/datasources/stylists_remote_data_source.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';
import 'package:urs_beauty/features/stylists/domain/repository/stylists_repository.dart';
 
 class StylistsRepositoryImpl implements StylistsRepository {
  final StylistsRemoteDataSource remoteDataSource;

  StylistsRepositoryImpl({required this.remoteDataSource});

@override
  Future<Either<Failures, List<Stylist>>> getStylists() async {
    try {
      final services = await remoteDataSource.getStylists();
      if (services.isEmpty) {
        return const Right([]);
      }
      else {
      return Right(services.map((e) => e.toEntity()).toList());
      }
    } on Failures catch (e) {
      return Left(e);
    }
  }
 }