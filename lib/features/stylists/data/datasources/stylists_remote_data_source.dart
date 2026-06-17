import 'package:geolocator/geolocator.dart';
import 'package:urs_beauty/features/stylists/data/models/stylist_availability_slot_model.dart';
import 'package:urs_beauty/features/stylists/data/models/stylists_availability_model.dart';
import 'package:urs_beauty/features/stylists/data/models/stylists_model.dart';
import 'package:urs_beauty/features/stylists/data/models/stylists_service_model.dart';

abstract class StylistsRemoteDataSource {
  Future<List<StylistModel>> getStylists();
  Future<List<StylistModel>> getStylistsByService(String serviceId);
  Future<StylistModel> getStylistDetail(String stylistId);
  Future<List<StylistModel>> searchStylists(String query);
  Future<List<StylistsServiceModel>> getStylistsServices(String stylistId);
  Future<List<StylistModel>> getNearByStylists(
    double latitude,
    double longitude,
    double radius,
  );
  Future<void> updateStylistsAvailability(
    StylistsAvailabilityModel availability,
  );
  Future<List<StylistsAvailabilityModel>> getStylistsAvailability(
    String stylistId,
  );
  Future<List<StylistsAvailabilityModel>> getStylistsAvailabilityByDay(
    String stylistId,
    String dayOfWeek,
  );
  Future<List<StylistAvailabilitySlotModel>> getStylistsAvailabilityByTime(
    String stylistId,
    String serviceId,
    DateTime selectedDate, {
    String? ignoredBookingId,
  });
  Future<Position> getClientLocation();

  Future<List<StylistModel>> fetchStylistsForService({
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
