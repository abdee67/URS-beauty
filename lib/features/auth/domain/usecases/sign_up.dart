import 'package:dartz/dartz.dart';

import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/auth/domain/repositories/auth_repository.dart';


class SignUp {
  final AuthRepository repo;
  SignUp(this.repo);

  Future<Either<Failures, void>> call(String email, String password, String firstName, String lastName, String phone) {
    return repo.signUp(email, password, firstName, lastName, phone);
  }
}
