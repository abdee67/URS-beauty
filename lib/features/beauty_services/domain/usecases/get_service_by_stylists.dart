import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/beauty_services/domain/entities/service_entity.dart';
import 'package:urs_beauty/features/beauty_services/domain/repositories/services_repository.dart';

class GetServiceByStylists {
  final ServiceRepository repository;
  GetServiceByStylists({required this.repository});

  Future<Either<Failures, List<ServiceEntity>>> call(String stylistsId) async {
    return await repository.getServiceByStylists(stylistsId);
  }
}