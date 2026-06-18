import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/discover/data/models/stylist_card_model.dart';
import 'package:urs_beauty/features/discover/domain/repositories/stylist_recommendation_repository.dart';

class FetchStylistRecommendations {
  const FetchStylistRecommendations(this.repository);

  final StylistRecommendationRepository repository;

  Future<Either<Failures, List<StylistCardModel>>> call({
    required String serviceId,
    required double clientLat,
    required double clientLng,
    required DateTime requestedDateTime,
    int limit = 20,
    int offset = 0,
  }) {
    return repository.fetchStylists(
      serviceId: serviceId,
      clientLat: clientLat,
      clientLng: clientLng,
      requestedDateTime: requestedDateTime,
      limit: limit,
      offset: offset,
    );
  }
}
