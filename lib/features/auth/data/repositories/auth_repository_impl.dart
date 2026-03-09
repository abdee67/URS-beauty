import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/config/supabase_config.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:urs_beauty/features/auth/data/models/client_model.dart';
import 'package:urs_beauty/features/auth/domain/entities/client.dart';
import 'package:urs_beauty/features/auth/domain/repositories/auth_repository.dart';
 class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  AuthRepositoryImpl(this.remoteDataSource);  
@override
Future<Either<Failures, Session>> signIn(
  String email,
  String password,
) async {
  try {
    // Attempt to sign in with email and password
    final result = await remoteDataSource.signIn(email, password);
    return Right(result);
    } catch (e) {
    return Left(Failures(message: e.toString()));
  }
}

  @override
  Future<Either<Failures, void>> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
    String phone,
  ) async {
    try {
     await remoteDataSource.signUp(email, password, firstName, lastName, phone);
      return const Right(null);
    } catch (e) {
      return Left(Failures(message: e.toString()));
    }
  }
 @override
  Future<Either<Failures, void>> sendOtp(String email) async {
    try {
      // Try resend first (for existing users)
      await remoteDataSource.sendOtp(email);
   
    return const Right(null);
    }  catch (otpError) {
        return Left(Failures(message: otpError.toString()));
      }
    }
 @override
  Future<Either<Failures, void>> verifyOtp(String email, String otp) async {
    try {
      await remoteDataSource.verifyOTP(email, otp);
      return const Right(null);
    } catch (e) {
      return Left(Failures(message: e.toString()));
    }
  }
 @override
  Future<Either<Failures, void>> signOut() async {
    try {
     await remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(Failures(message: e.toString()));
    }
  }
  @override
  Future<Either<Failures, ClientModel>> getCurrentClient() async {
    try {
      final user = remoteDataSource.getCurrentClient();
      return Right(await user);
    } catch (e) {
      return Left(Failures(message: e.toString()));
    }
  }
  @override
  Future<Either<Failures, ClientEntity>> updateClientProfile(ClientEntity client) async {
    try {
      final clientModel = ClientModel(
        id: client.id,
        email: client.email,
        firstName: client.firstName,
        lastName: client.lastName,
        phone: client.phone,
      );
      await remoteDataSource.updateClientProfile(clientModel);
      return Right(client);
    } catch (e) {
      return Left(Failures(message: e.toString()));
    }
  }
  @override
  Future<Either<Failures, void>> forgotPassword(String email) async {
    try {
      await SupabaseConfig.client.auth.resetPasswordForEmail(email, redirectTo: 'ursbeauty://reset-password/');
      return const Right(null);
    } catch (e) {
      return Left(Failures(message: e.toString()));
    }
  }
  @override
  Future<Either<Failures, void>> resetPassword(String email, String password) async {
    try {
   await remoteDataSource.resetPassword(email, password);
      return const Right(null);
    } catch (e) {
      return Left(Failures(message: e.toString()));
    }
  }
}
