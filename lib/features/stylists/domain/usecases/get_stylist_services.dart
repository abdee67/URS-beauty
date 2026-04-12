import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylists_service.dart';
import 'package:urs_beauty/features/stylists/domain/repository/stylists_repository.dart';

class GetStylistServices {
  const GetStylistServices(this.repository);

  final StylistsRepository repository;

  Future<Either<Failures, List<StylistsServiceEntity>>> call(
    String stylistId,
  ) async {
    final result = await repository.getStylistsServices(stylistId);
    return result.fold(
      (failure) => Left(failure),
      (services) => Right(services.cast<StylistsServiceEntity>()),
    );
  }
}
