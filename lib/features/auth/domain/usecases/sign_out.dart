import 'package:dartz/dartz.dart';

import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/auth/domain/repositories/auth_repository.dart';

class SignOut {
  final AuthRepository repo;
  SignOut(this.repo);

  Future<Either<Failures, void>> call() {
    return repo.signOut();
  }
}
