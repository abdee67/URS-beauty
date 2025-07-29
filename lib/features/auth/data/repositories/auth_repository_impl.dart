import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/config/supabase_config.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/auth/domain/entities/client.dart';

class AuthRepositoryImpl {
  Future<Either<Failures, Session>> signIn(
    String email,
    String password,
  ) async {
    try {
      // Attempt to sign in with email and password
      final result = await SupabaseConfig.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return Right(result.session!);
    } catch (e) {
      return Left(Failures(message: e.toString()));
    }
  }

  Future<Either<Failures, void>> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
    String phone,
  ) async {
    try {
      await SupabaseConfig.client.auth.signUp(
        email: email,
        password: password,
        data: {'first_name': firstName, 'last_name': lastName, 'phone': phone},
        emailRedirectTo: 'ursbeauty://login/', // for deep linking
      );
      return const Right(null);
    } catch (e) {
      return Left(Failures(message: e.toString()));
    }
  }

  Future<Either<Failures, void>> sendOtp(String email) async {
    try {
      // Try resend first (for existing users)
      await SupabaseConfig.client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      return const Right(null);
    } catch (e) {
      // If resend fails, try signInWithOtp (for new users)
      try {
        await SupabaseConfig.client.auth.signInWithOtp(
          email: email,
          shouldCreateUser: true,
        );
        return const Right(null);
      } catch (otpError) {
        return Left(Failures(message: otpError.toString()));
      }
    }
  }

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

  Future<Either<Failures, void>> signOut() async {
    try {
      await SupabaseConfig.client.auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(Failures(message: e.toString()));
    }
  }

  Future<Either<Failures, Client>> getCurrentClient() async {
    try {
      final user = SupabaseConfig.client.auth.currentUser;
      return Right(Client(id: user!.id, email: user.email!, firstName: user.userMetadata?['first_name'] ?? '', lastName: user.userMetadata?['last_name'] ?? '', phone: int.parse(user.userMetadata?['phone'] ?? '0')));
    } catch (e) {
      return Left(Failures(message: e.toString()));
    }
  }
  Future<Either<Failures, Client>> updateClientProfile(Client client) async {
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
      return Right(Client(id: client.id, email: client.email, firstName: client.firstName, lastName: client.lastName, phone: client.phone));
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
