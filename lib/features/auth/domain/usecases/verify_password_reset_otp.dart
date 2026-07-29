import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/auth/domain/repositories/auth_repository.dart';

class VerifyPasswordResetOtp {
  final AuthRepository authRepository;

  VerifyPasswordResetOtp(this.authRepository);

  Future<Either<Failures, void>> call(String email, String otp) {
    return authRepository.verifyPasswordResetOtp(email, otp);
  }
}
