import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/stylists/data/models/stylists_availability_model.dart';
import 'package:urs_beauty/features/stylists/domain/repository/stylists_repository.dart';

class GetStylistsAvailability {
  final StylistsRepository repository;
  const GetStylistsAvailability(this.repository);

  Future<Either<Failures, List<StylistsAvailabilityModel>>> call(String stylistId) async {
    return await repository.getStylistsAvailability(stylistId);
  }
}