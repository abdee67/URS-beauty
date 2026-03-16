import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/beauty_services/data/datasources/service_remote_data_source.dart';
import 'package:urs_beauty/features/beauty_services/domain/entities/service_entity.dart';
import 'package:urs_beauty/features/beauty_services/domain/repositories/services_repository.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceRemoteDataSource remoteDataSource;
  ServiceRepositoryImpl({required this.remoteDataSource});

@override
  Future<Either<Failures, List<ServiceEntity>>> getServices() async {
    try{
    final result = await  remoteDataSource.getServices();
          return Right(result.map((e) => e.toEntity()).toList());
    } on Failures catch (e) {
      if(kDebugMode) {
        print('Error fetching services: ${e.message}');
      }
      return  Left(Failures(message: 'No services found'));
    } 
  }
  

@override
  Future<Either<Failures, List<ServiceEntity>>> getServiceByCategory(String categoryId) async {
    try{
    final result = await remoteDataSource.getServiceByCategory(categoryId);
      return Right(result.map((e) => e.toEntity()).toList());
    }
   on Failures catch (e) {
    if(kDebugMode) {
      print('Error fetching services by category: ${e.message}');
    }
    return Left(Failures(message: 'No services found for the given category'));
  }
  }

@override
  Future<Either<Failures, List<ServiceEntity>>> getServiceByProfessionals(String professionalsId) async {
    try{
    final result = await remoteDataSource.getServiceByProfessionals(professionalsId);
      return Right(result.map((e) => e.toEntity()).toList());
  } on Failures catch (e) {
    if(kDebugMode) {
      print('Error fetching services by professionals: ${e.message}');
    }
    return Left(Failures(message: 'No services found for the given professionals'));
  }
  }
@override
  Future<Either<Failures, ServiceEntity>> getServiceDetail(String serviceId) async {
    try{
    final result = await remoteDataSource.getServiceDetail(serviceId);
      return Right(result.toEntity());
    } on Failures catch (e) {
      if(kDebugMode) {
        print('Error fetching service detail: ${e.message}');
      }
      return Left(Failures(message: 'Service not found'));
    }
  }

@override
  Future<Either<Failures, List<ServiceEntity>>> searchServices(String query) async {
    try {
      final result = await remoteDataSource.searchServices(query);
      return Right(result.map((e) => e.toEntity()).toList());
    } on Failures catch (e) {
      if(kDebugMode) {
        print('Error searching services: ${e.message}');
      }
      return Left(Failures(message: 'No services found matching the search query'));
    }
  }
}