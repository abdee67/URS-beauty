import 'package:geolocator/geolocator.dart';
import 'package:urs_beauty/features/discover/data/models/stylist_card_model.dart';
import 'package:urs_beauty/features/stylists/data/models/stylist_availability_slot_model.dart';

abstract class StylistRecommendationRemoteDataSource {
  Future<Position> getClientLocation();

  Future<List<StylistCardModel>> fetchStylists({
    required String serviceId,
    required double clientLat,
    required double clientLng,
    required DateTime requestedDateTime,
    int limit = 20,
    int offset = 0,
  });

  Future<List<StylistAvailabilitySlotModel>> fetchAvailableSlots({
    required String stylistId,
    required String serviceId,
    required DateTime date,
    String? ignoredBookingId,
  });
}
