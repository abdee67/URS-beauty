import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/beauty_services/data/datasources/service_categories_remote_data_source.dart';
import 'package:urs_beauty/features/beauty_services/domain/entities/service_category_entity.dart';
import 'package:urs_beauty/features/beauty_services/domain/repositories/service_categories_repository.dart';

class ServiceCategoriesRepositoryImpl implements ServiceCategoriesRepository {
  final ServiceCategoriesRemoteDataSource remoteDataSource;

  ServiceCategoriesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failures, List<ServiceCategories>>> getServiceCategories() async {
    try{
    final services =  await remoteDataSource.getServiceCategories(); 
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