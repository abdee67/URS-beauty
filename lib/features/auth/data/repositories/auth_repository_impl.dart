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
    int phone,
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
  Future<Either<Failures, void>> verifyOTP(String email, String otp) async {
    try {
      await SupabaseConfig.client.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.email,
      );
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
  Future<Either<Failures, ClientModel>> getCurrentClient() async {//i setupd out here...wll back to this later
    try {
      final user = remoteDataSource.getCurrentClient();
      return Right(ClientModel(id: user!.id, email: user.email!, firstName: user.userMetadata?['first_name'] ?? '', lastName: user.userMetadata?['last_name'] ?? '', phone: int.parse(user.userMetadata?['phone'] ?? '0')));
    } catch (e) {
      return Left(Failures(message: e.toString()));
    }
  }
  Future<Either<Failures, ClientModel>> updateClientProfile(ClientModel client) async {
    try {
      await SupabaseConfig.client.auth.updateUser(
        UserAttributes(
          email: client.email,
          data: {
            'first_name': client.firstName,
            'last_name': client.lastName,
            'phone': client.phone.toString(),
          },
        ),
      );
      return Right(ClientModel(id: client.id, email: client.email, firstName: client.firstName, lastName: client.lastName, phone: client.phone));
    } catch (e) {
      return Left(Failures(message: e.toString()));
    }
  }
  Future<Either<Failures, void>> forgotPassword(String email) async {
    try {
      await SupabaseConfig.client.auth.resetPasswordForEmail(email, redirectTo: 'ursbeauty://reset-password/');
      return const Right(null);
    } catch (e) {
      return Left(Failures(message: e.toString()));
    }
  }
  Future<Either<Failures, void>> resetPassword(String email, String password) async {
    try {
      await SupabaseConfig.client.auth.updateUser(UserAttributes(email: email, password: password));
      return const Right(null);
    } catch (e) {
      return Left(Failures(message: e.toString()));
    }
  }
}
