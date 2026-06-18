import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/discover/data/datasources/stylist_recommendation_remote_data_source.dart';
import 'package:urs_beauty/features/discover/data/models/stylist_card_model.dart';
import 'package:urs_beauty/features/discover/domain/repositories/stylist_recommendation_repository.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_availability_slot_entity.dart';

class StylistRecommendationRepositoryImpl
    implements StylistRecommendationRepository {
  const StylistRecommendationRepositoryImpl({required this.remoteDataSource});

  final StylistRecommendationRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failures, Position>> getClientLocation() async {
    try {
      return Right(await remoteDataSource.getClientLocation());
    } on Failures catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failures, List<StylistCardModel>>> fetchStylists({
    required String serviceId,
    required double clientLat,
    required double clientLng,
    required DateTime requestedDateTime,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final stylists = await remoteDataSource.fetchStylists(
        serviceId: serviceId,
        clientLat: clientLat,
        clientLng: clientLng,
        requestedDateTime: requestedDateTime,
        limit: limit,
        offset: offset,
      );
      return Right(stylists);
    } on Failures catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failures, List<StylistAvailabilitySlotEntity>>>
  fetchAvailableSlots({
    required String stylistId,
    required String serviceId,
    required DateTime date,
    String? ignoredBookingId,
  }) async {
    try {
      final slots = await remoteDataSource.fetchAvailableSlots(
        stylistId: stylistId,
        serviceId: serviceId,
        date: date,
        ignoredBookingId: ignoredBookingId,
      );
      return Right(slots);
    } on Failures catch (e) {
      return Left(e);
    }
  }
}
