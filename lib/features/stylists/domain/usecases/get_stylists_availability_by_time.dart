import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/stylists/data/models/stylists_availability_model.dart';
import 'package:urs_beauty/features/stylists/domain/repository/stylists_repository.dart';

class GetStylistsAvailabilityByTime {
  final StylistsRepository repository;
   const GetStylistsAvailabilityByTime(this.repository);

   Future<Either<Failures, List<StylistsAvailabilityModel>>> call(String stylistId, String dayOfWeek, String time) async {
    return await repository.getStylistsAvailabilityByTime(stylistId, dayOfWeek, time);
   }
}