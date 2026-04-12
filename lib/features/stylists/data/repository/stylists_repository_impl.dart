  import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/stylists/data/datasources/stylists_remote_data_source.dart';
import 'package:urs_beauty/features/stylists/data/models/stylists_availability_model.dart';
import 'package:urs_beauty/features/stylists/data/models/stylists_service_model.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';
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
      }
      else {
      return Right(services.map((e) => e.toEntity()).toList());
      }
    } on Failures catch (e) {
      return Left(e);
    }
  }
  @override
  Future<Either<Failures, List<Stylist>>> getStylistsByService(String serviceId) async {
    try {
      final stylists = await remoteDataSource.getStylistsByService(serviceId);
      if (stylists.isEmpty) {
        return const Right([]);
      }
      else {
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
      }
      else {
      return Right(stylists.map((e) => e.toEntity()).toList());
      }
    } on Failures catch (e) {
      return Left(e);
    }
  }
  @override
  Future<Either<Failures, List<StylistsServiceModel>>> getStylistsServices(String stylistId) async {
    try {
      final services = await remoteDataSource.getStylistsServices(stylistId);
      if (services.isEmpty) {
        return const Right([]);
      }
      else {
      return Right(services);
      }
    } on Failures catch (e) {
      return Left(e);
    }
  }
  @override
  Future<Either<Failures, List<Stylist>>> getNearByStylists(double latitude, double longitude, double radius) async {
    try {
      final stylists = await remoteDataSource.getNearByStylists(latitude, longitude, radius);
      if (stylists.isEmpty) {
        return const Right([]);
      }
      else {
      return Right(stylists.map((e) => e.toEntity()).toList());
      }
    } on Failures catch (e) {
      return Left(e);
    }
  }
  @override
  Future<Either<Failures, void>> updateStylistsAvailability(StylistsAvailabilityModel availability) async {
    try {
      await remoteDataSource.updateStylistsAvailability(availability);
      return const Right(null);
    } on Failures catch (e) {
      return Left(e);
    }
  }
  @override
  Future<Either<Failures, List<StylistsAvailabilityModel>>> getStylistsAvailability(String stylistId) async {
    try {
      final availability = await remoteDataSource.getStylistsAvailability(stylistId);
      return Right(availability);
    } on Failures catch (e) {
      return Left(e);
    }
  }
  @override
  Future<Either<Failures, List<StylistsAvailabilityModel>>> getStylistsAvailabilityByDay(String stylistId, String dayOfWeek) async {
    try {
      final availability = await remoteDataSource.getStylistsAvailabilityByDay(stylistId, dayOfWeek);
      return Right(availability);
    } on Failures catch (e) {
      return Left(e);
    }
 } @override
  Future<Either<Failures, List<StylistsAvailabilityModel>>> getStylistsAvailabilityByTime(String stylistId, String dayOfWeek, String time) async {
    try {
      final availability = await remoteDataSource.getStylistsAvailabilityByTime(stylistId, dayOfWeek, time);
      return Right(availability);
    } on Failures catch (e) {
      return Left(e);
    }
  }
 }