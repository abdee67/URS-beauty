import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/stylists/domain/repository/stylists_repository.dart';

class GetClientLocation {
  const GetClientLocation(this.repository);

  final StylistsRepository repository;

  Future<Either<Failures, Position>> call() {
    return repository.getClientLocation();
  }
}