import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/home/domain/entities/services.dart';
import 'package:urs_beauty/features/home/domain/repositories/home_repository.dart';

class GetServices {
  final HomeRepository repository;

  GetServices(this.repository);

  Future<Either<Failures, List<Services>>> call() async {
    return await repository.getServices();
  }
}