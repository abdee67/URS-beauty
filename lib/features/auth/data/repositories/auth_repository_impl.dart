import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/config/supabase_config.dart';
import 'package:urs_beauty/core/errors/failures.dart';

class AuthRepositoryImpl {
  Future<Either<Failures, Session>> signIn(String email, String password) async {
    try {
      // Attempt to sign in with email and password
     final result =  await SupabaseConfig.client.auth.signInWithPassword(
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
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
        },
        emailRedirectTo: 'ursbeauty://verify/', // for deep linking
      );
      return const Right(null);
    } catch (e) {
      return Left(Failures(message: e.toString()));
    }
  }
}
