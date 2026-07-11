import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylists_availability_entity.dart';
import 'package:urs_beauty/features/stylists/domain/repository/stylists_repository.dart';

class GetStylistsAvailabilityByDay {
  final StylistsRepository repository;
  const GetStylistsAvailabilityByDay(this.repository);

  Future<Either<Failures, List<StylistsAvailability>>> call(String stylistId, String dayOfWeek) async {
    return await repository.getStylistsAvailabilityByDay(stylistId, dayOfWeek);
  }
}