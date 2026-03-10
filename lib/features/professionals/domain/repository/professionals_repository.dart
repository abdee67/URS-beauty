    import 'package:urs_beauty/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:urs_beauty/features/professionals/domain/entities/professioanls.dart';
abstract class ProfessionalsRepository {
Future<Either<Failures, List<Professionals>>> getProfessionals();
}