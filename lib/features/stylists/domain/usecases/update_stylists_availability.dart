import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylists_availability_entity.dart';
import 'package:urs_beauty/features/stylists/domain/repository/stylists_repository.dart';

class UpdateStylistsAvailability {
  final StylistsRepository repository;
  const UpdateStylistsAvailability(this.repository);

  Future<Either<Failures, void>> call(StylistsAvailability availability) async {
    return await repository.updateStylistsAvailability(availability);
  }
}