import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/stylists/data/models/stylists_availability_model.dart';
import 'package:urs_beauty/features/stylists/domain/repository/stylists_repository.dart';

class UpdateStylistsAvailability {
  final StylistsRepository repository;
  const UpdateStylistsAvailability(this.repository);

  Future<Either<Failures, void>> call(StylistsAvailabilityModel availability) async {
    return await repository.updateStylistsAvailability(availability);
  }
}