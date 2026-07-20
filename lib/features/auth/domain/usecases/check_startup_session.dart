import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/auth/domain/repositories/auth_repository.dart';

class CheckStartupSession {
  final AuthRepository repository;

  CheckStartupSession(this.repository);

  Future<Either<Failures, String>> call() {
    return repository.checkStartupSession();
  }
}