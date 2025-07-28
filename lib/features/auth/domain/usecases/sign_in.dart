import 'package:dartz/dartz.dart';

import 'package:gotrue/src/types/session.dart';

import 'package:urs_beauty/core/errors/failures.dart';

import '../../data/repositories/auth_repository_impl.dart';

class SignIn {
  final AuthRepositoryImpl repo;
  SignIn(this.repo);

  Future<Either<Failures, Session>> call(String email, String password) {
    return repo.signIn(email, password);
  }
}
