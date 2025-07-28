import 'package:dartz/dartz.dart';

import 'package:urs_beauty/core/errors/failures.dart';

import '../../data/repositories/auth_repository_impl.dart';

class SignOut {
  final AuthRepositoryImpl repo;
  SignOut(this.repo);

  Future<Either<Failures, void>> call() {
    return repo.signOut();
  }
}
