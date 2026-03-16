import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/auth/domain/repositories/auth_repository.dart';

class SendOtp{
  final AuthRepository repository;

  SendOtp(this.repository);

  Future<Either<Failures, void >> call(String email){
    return repository.sendOtp(email);
  }
} 