import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/home/domain/entities/professioanls.dart';
import 'package:urs_beauty/features/home/domain/repositories/home_repository.dart';

class GetProfessionals {
  final HomeRepository repository;

  GetProfessionals(this.repository,);

  Future<Either<Failures, List<Professionals>>> call() async {
    return await repository.getProfessionals();
  }
}