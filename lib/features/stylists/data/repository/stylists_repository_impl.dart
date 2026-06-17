import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/stylists/data/datasources/stylists_remote_data_source.dart';
import 'package:urs_beauty/features/stylists/data/models/stylists_model.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_availability_slot_entity.dart';
import 'package:urs_beauty/features/stylists/data/models/stylists_availability_model.dart';
import 'package:urs_beauty/features/stylists/data/models/stylists_service_model.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylists_availability_entity.dart';
import 'package:urs_beauty/features/stylists/domain/repository/stylists_repository.dart';

class StylistsRepositoryImpl implements StylistsRepository {
  final StylistsRemoteDataSource remoteDataSource;

  StylistsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failures, List<Stylist>>> getStylists() async {
    try {
      final services = await remoteDataSource.getStylists();
      if (services.isEmpty) {
        return const Right([]);
      } else {
        return Right(services.map((e) => e.toEntity()).toList());
      }
    } on Failures catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failures, List<Stylist>>> getStylistsByService(
    String serviceId,
  ) async {
    try {
      final stylists = await remoteDataSource.getStylistsByService(serviceId);
      if (stylists.isEmpty) {
        return const Right([]);
      } else {
        return Right(stylists.map((e) => e.toEntity()).toList());
      }
    } on Failures catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failures, Stylist>> getStylistDetail(String stylistId) async {
    try {
      final stylist = await remoteDataSource.getStylistDetail(stylistId);
      return Right(stylist.toEntity());
    } on Failures catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failures, List<Stylist>>> searchStylists(String query) async {
    try {
      final stylists = await remoteDataSource.searchStylists(query);
      if (stylists.isEmpty) {
        return const Right([]);
      } else {
        return Right(stylists.map((e) => e.toEntity()).toList());
      }
    } on Failures catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failures, List<StylistsServiceModel>>> getStylistsServices(
    String stylistId,
  ) async {
    try {
      final services = await remoteDataSource.getStylistsServices(stylistId);
      if (services.isEmpty) {
        return const Right([]);
      } else {
        return Right(services);
      }
    } on Failures catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failures, List<Stylist>>> getNearByStylists(
    double latitude,
    double longitude,
    double radius,
  ) async {
    try {
      final stylists = await remoteDataSource.getNearByStylists(
        latitude,
        longitude,
        radius,
      );
      if (stylists.isEmpty) {
        return const Right([]);
      } else {
        return Right(stylists.map((e) => e.toEntity()).toList());
      }
    } on Failures catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failures, void>> updateStylistsAvailability(
    availability,
  ) async {
    try {
      final model = StylistsAvailabilityModel.fromEntity(availability);
      await remoteDataSource.updateStylistsAvailability(model);
      return const Right(null);
    } on Failures catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failures, List<StylistsAvailabilityModel>>>
  getStylistsAvailability(String stylistId) async {
    try {
      final availability = await remoteDataSource.getStylistsAvailability(
        stylistId,
      );
      return Right(availability);
    } on Failures catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failures, List<StylistsAvailabilityModel>>>
  getStylistsAvailabilityByDay(String stylistId, String dayOfWeek) async {
    try {
      final availability = await remoteDataSource.getStylistsAvailabilityByDay(
        stylistId,
        dayOfWeek,
      );
      return Right(availability);
    } on Failures catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failures, List<StylistAvailabilitySlotEntity>>>
  getStylistsAvailabilityByTime(
    String stylistId,
    String serviceId,
    DateTime selectedDate, {
    String? ignoredBookingId,
  }) async {
    try {
      final availability = await remoteDataSource.getStylistsAvailabilityByTime(
        stylistId,
        serviceId,
        selectedDate,
        ignoredBookingId: ignoredBookingId,
      );
      return Right(availability);
    } on Failures catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failures, Position>> getClientLocation() async {
    try {
      return Right(await remoteDataSource.getClientLocation());
    } on Failures catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failures, List<StylistModel>>> fetchStylistsForService({
    required String serviceId,
    required double clientLat,
    required double clientLng,
    required DateTime requestedDateTime,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final stylists = await remoteDataSource.fetchStylistsForService(
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
