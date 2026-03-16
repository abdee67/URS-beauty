  import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/professionals/data/datasources/professionals_remote_data_source.dart';
import 'package:urs_beauty/features/professionals/domain/entities/professioanls.dart';
import 'package:urs_beauty/features/professionals/domain/repository/professionals_repository.dart';
 
 class ProfessionalsRepositoryImpl implements ProfessionalsRepository {
  final ProfessionalsRemoteDataSource remoteDataSource;

  ProfessionalsRepositoryImpl({required this.remoteDataSource});

@override
  Future<Either<Failures, List<Professionals>>> getProfessionals() async {
    try {
      final services = await remoteDataSource.getProfessionals();
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