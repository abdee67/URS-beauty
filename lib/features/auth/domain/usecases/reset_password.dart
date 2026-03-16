import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/auth/domain/repositories/auth_repository.dart';

class ResetPassword {
  final AuthRepository authRepo;
  ResetPassword(this.authRepo);
  Future<Either<Failures, void>> call(String email, String password) async => await authRepo.resetPassword(email, password); //Future<void> call(String email, String password) async {
  }