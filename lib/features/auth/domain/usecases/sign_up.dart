import 'package:dartz/dartz.dart';

import 'package:urs_beauty/core/errors/failures.dart';

import '../../data/repositories/auth_repository_impl.dart';

class SignUp {
  final AuthRepositoryImpl repo;
  SignUp(this.repo);

  Future<Either<Failures, void>> call(String email, String password, String firstName, String lastName, int phone) {
    return repo.signUp(email, password, firstName, lastName, phone.toString());
  }
}
