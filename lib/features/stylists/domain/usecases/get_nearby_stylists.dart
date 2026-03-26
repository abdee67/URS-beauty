import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';
import 'package:urs_beauty/features/stylists/domain/repository/stylists_repository.dart';

class GetNearbyStylists {
  final StylistsRepository repository;
  const GetNearbyStylists(this.repository);

  Future<Either<Failures, List<Stylist>>> call(double latitude, double longitude, double radius) async {
    return await repository.getNearByStylists(latitude, longitude, radius);
  }
}