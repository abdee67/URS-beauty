import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/discover/data/models/stylist_card_model.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_availability_slot_entity.dart';

abstract class StylistRecommendationRepository {
  Future<Either<Failures, Position>> getClientLocation();

  Future<Either<Failures, List<StylistCardModel>>> fetchStylists({
    required String serviceId,
    required double clientLat,
    required double clientLng,
    required DateTime requestedDateTime,
    int limit = 20,
    int offset = 0,
  });

  Future<Either<Failures, List<StylistAvailabilitySlotEntity>>>
  fetchAvailableSlots({
    required String stylistId,
    required String serviceId,
    required DateTime date,
    String? ignoredBookingId,
  });
}
