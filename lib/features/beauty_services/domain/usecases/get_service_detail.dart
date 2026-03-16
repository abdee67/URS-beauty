import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/beauty_services/domain/entities/service_entity.dart';
import 'package:urs_beauty/features/beauty_services/domain/repositories/services_repository.dart';

class GetServiceDetail {
  final ServiceRepository serviceRepository;
  GetServiceDetail(this.serviceRepository);

  Future<Either<Failures, ServiceEntity>> call(String serviceId) async {
    return await serviceRepository.getServiceDetail(serviceId);
  }
}