    import 'package:urs_beauty/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:urs_beauty/features/stylists/data/models/stylists_availability_model.dart';
import 'package:urs_beauty/features/stylists/data/models/stylists_service_model.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';
abstract class StylistsRepository {
Future<Either<Failures, List<Stylist>>> getStylists();
Future<Either<Failures, List<Stylist>>> getStylistsByService(String serviceId);
Future<Either<Failures, Stylist>> getStylistDetail(String stylistId);
Future<Either<Failures, List<Stylist>>> searchStylists(String query);
Future<Either<Failures, List<StylistsServiceModel>>> getStylistsServices(String stylistId);
Future<Either<Failures, List<Stylist>>> getNearByStylists(double latitude, double longitude, double radius);
Future<Either<Failures, void>> updateStylistsAvailability(StylistsAvailabilityModel availability);
Future<Either<Failures, List<StylistsAvailabilityModel>>> getStylistsAvailability(String stylistId);
Future<Either<Failures, List<StylistsAvailabilityModel>>> getStylistsAvailabilityByDay(String stylistId, String dayOfWeek);
Future<Either<Failures, List<StylistsAvailabilityModel>>> getStylistsAvailabilityByTime(String stylistId, String dayOfWeek, String time);
}