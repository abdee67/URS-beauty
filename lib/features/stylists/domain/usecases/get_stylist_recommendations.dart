import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';
import 'package:urs_beauty/features/stylists/domain/repository/stylists_repository.dart';

class GetStylistRecommendations {
  const GetStylistRecommendations(this.repository);

  final StylistsRepository repository;

  Future<Either<Failures, List<Stylist>>> call({
    required String serviceId,
    required double clientLat,
    required double clientLng,
    required DateTime requestedDateTime,
    int limit = 20,
    int offset = 0,
  }) {
    return repository.fetchStylistsForService(
      serviceId: serviceId,
      clientLat: clientLat,
      clientLng: clientLng,
      requestedDateTime: requestedDateTime,
      limit: limit,
      offset: offset,
    );
  }
}
