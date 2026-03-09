import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/auth/domain/entities/client.dart';

abstract class AuthRepository {
Future <Either<Failures, void>> signUp(String email, String password, String firstName, String lastName, String phone);
Future <Either<Failures, Session>> signIn(String email, String password);
Future<Either<Failures, void>> sendOtp(String email);
Future<Either<Failures, void>> verifyOtp(String email, String otp);
Future<Either<Failures, ClientEntity>> getCurrentClient();
Future<Either<Failures, void>> signOut();
Future<Either<Failures, ClientEntity>> updateClientProfile(ClientEntity client);
Future<Either<Failures, void>> resetPassword(String email, String password);
Future<Either<Failures, void>> forgotPassword(String email);

}