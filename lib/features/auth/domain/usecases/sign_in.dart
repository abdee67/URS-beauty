import 'package:dartz/dartz.dart';

import 'package:gotrue/src/types/session.dart';

import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/auth/domain/repositories/auth_repository.dart';


class SignIn {
  final AuthRepository repo;
  SignIn(this.repo);


  Future<Either<Failures, Session>> call(String email, String password) {
    return repo.signIn(email, password);
  }
}
