import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/config/supabase_config.dart';
import 'package:urs_beauty/core/errors/failures.dart';

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
}
