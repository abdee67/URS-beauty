import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_availability_slot_entity.dart';
import 'package:urs_beauty/features/stylists/domain/repository/stylists_repository.dart';

class GetAvailableSlots {
  const GetAvailableSlots(this.repository);

  final StylistsRepository repository;

  Future<Either<Failures, List<StylistAvailabilitySlotEntity>>> call({
    required String stylistId,
    required String serviceId,
    required DateTime date,
    String? ignoredBookingId,
  }) {
    return repository.fetchAvailableSlots(
      stylistId: stylistId,
      serviceId: serviceId,
      date: date,
      ignoredBookingId: ignoredBookingId,
    );
  }
}