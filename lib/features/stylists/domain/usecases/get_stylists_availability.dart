import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylists_availability_entity.dart';
import 'package:urs_beauty/features/stylists/domain/repository/stylists_repository.dart';

class GetStylistsAvailability {
  final StylistsRepository repository;
  const GetStylistsAvailability(this.repository);

  Future<Either<Failures, List<StylistsAvailability>>> call(String stylistId) async {
    return await repository.getStylistsAvailability(stylistId);
  }
}