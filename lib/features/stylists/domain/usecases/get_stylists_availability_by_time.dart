import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_availability_slot_entity.dart';
import 'package:urs_beauty/features/stylists/domain/repository/stylists_repository.dart';

class GetStylistsAvailabilityByTime {
  final StylistsRepository repository;
   const GetStylistsAvailabilityByTime(this.repository);

   Future<Either<Failures, List<StylistAvailabilitySlotEntity>>> call(
    String stylistId,
    String serviceId,
    DateTime selectedDate, {
    String? ignoredBookingId,
   }) async {
    return await repository.getStylistsAvailabilityByTime(
      stylistId,
      serviceId,
      selectedDate,
      ignoredBookingId: ignoredBookingId,
    );
   }
}
