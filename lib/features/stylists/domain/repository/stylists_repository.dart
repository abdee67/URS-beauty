import 'package:geolocator/geolocator.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_availability_slot_entity.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylists_availability_entity.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylists_service.dart';

abstract class StylistsRepository {
  Future<Either<Failures, List<Stylist>>> getStylists();
  Future<Either<Failures, List<Stylist>>> getStylistsByService(
    String serviceId,
  );
  Future<Either<Failures, Stylist>> getStylistDetail(String stylistId);
  Future<Either<Failures, List<Stylist>>> searchStylists(String query);
  Future<Either<Failures, List<StylistsServiceEntity>>> getStylistsServices(
    String stylistId,
  );
  Future<Either<Failures, List<Stylist>>> getNearByStylists(
    double latitude,
    double longitude,
    double radius,
  );
  Future<Either<Failures, void>> updateStylistsAvailability(
    StylistsAvailability availability,
  );
  Future<Either<Failures, List<StylistsAvailability>>>
  getStylistsAvailability(String stylistId);
  Future<Either<Failures, List<StylistsAvailability>>>
  getStylistsAvailabilityByDay(String stylistId, String dayOfWeek);
  Future<Either<Failures, List<StylistAvailabilitySlotEntity>>>
  getStylistsAvailabilityByTime(
    String stylistId,
    String serviceId,
    DateTime selectedDate, {
    String? ignoredBookingId,
  });
  Future<Either<Failures, Position>> getClientLocation();

  Future<Either<Failures, List<Stylist>>> fetchStylistsForService({
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
