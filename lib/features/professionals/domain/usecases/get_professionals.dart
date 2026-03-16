import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/professionals/domain/entities/professioanls.dart';
import 'package:urs_beauty/features/professionals/domain/repository/professionals_repository.dart';

class GetProfessionals {
  final ProfessionalsRepository repository;

  GetProfessionals(this.repository,);

  Future<Either<Failures, List<Professionals>>> call() async {
    return await repository.getProfessionals();
  }
}