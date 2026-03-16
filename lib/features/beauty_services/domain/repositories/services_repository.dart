import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/beauty_services/domain/entities/service_entity.dart';

abstract class ServiceRepository {

  Future <Either<Failures, List<ServiceEntity>>> getServices();
  Future <Either<Failures, List<ServiceEntity>>> getServiceByCategory(String categoryId);
  Future <Either<Failures, List<ServiceEntity>>> getServiceByProfessionals(String professionalsId);
  Future <Either<Failures, ServiceEntity>> getServiceDetail(String serviceId);
  Future <Either<Failures, List<ServiceEntity>>> searchServices(String query);

}