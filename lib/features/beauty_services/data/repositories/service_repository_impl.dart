import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/core/errors/exceptions/service_exceptions.dart';
import 'package:urs_beauty/core/errors/failures/service_failures.dart';
import 'package:urs_beauty/features/beauty_services/data/datasources/service_remote_data_source.dart';
import 'package:urs_beauty/features/beauty_services/domain/entities/service_entity.dart';
import 'package:urs_beauty/features/beauty_services/domain/repositories/services_repository.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceRemoteDataSource remoteDataSource;
  ServiceRepositoryImpl({required this.remoteDataSource});

@override
  Future<Either<Failures, List<ServiceEntity>>> getServices() async {
    return serviceRepositoryOperation(() async {
      final result = await remoteDataSource.getServices();
      return result.map((e) => e.toEntity()).toList();
    });
  }
  

@override
  Future<Either<Failures, List<ServiceEntity>>> getServiceByCategory(String categoryId) async {
    return serviceRepositoryOperation(() async {
      final result = await remoteDataSource.getServiceByCategory(categoryId);
      return result.map((e) => e.toEntity()).toList();
    });
  }

@override
  Future<Either<Failures, List<ServiceEntity>>> getServiceByStylists(String stylistsId) async {
    return serviceRepositoryOperation(() async {
      final result = await remoteDataSource.getServiceByStylists(stylistsId);
      return result.map((e) => e.toEntity()).toList();
    });
  }
@override
  Future<Either<Failures, ServiceEntity>> getServiceDetail(String serviceId) async {
    return serviceRepositoryOperation(() async {
      final result = await remoteDataSource.getServiceDetail(serviceId);
      return result.toEntity();
    });
  }

@override
  Future<Either<Failures, List<ServiceEntity>>> searchServices(String query) async {
    return serviceRepositoryOperation(() async {
      final result = await remoteDataSource.searchServices(query);
      return result.map((e) => e.toEntity()).toList();
    });
  }


}
