  import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/beauty_services/domain/entities/service_category_entity.dart';
import 'package:urs_beauty/features/professionals/data/datasources/professionals_remote_data_source.dart';
 
 class ProfessionalsRepositoryImpl implements ProfessionalsRemoteDataSource {

@override
  Future<Either<Failures, List<ServiceCategories>>> getServices() async {
    try {
      final services = await remoteDataSource.getServices();
      return Right(services.map((e) => e.toEntity()).toList());
    } on Failures catch (e) {
      return Left(e);
    }
  }
 }