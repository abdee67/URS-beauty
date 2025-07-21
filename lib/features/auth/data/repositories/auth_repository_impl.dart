import 'package:dartz/dartz.dart';
import '../../../../config/supabase_config.dart';

class AuthRepositoryImpl {
  Future<Either<Failure, void>> signIn(String email, String password) async {
    try {
      await SupabaseConfig.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return const Right(null);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  Future<Either<Failure, void>> signUp(String email, String password, String lastName, String firstName, String phone) async {
    try {
      await SupabaseConfig.client.auth.signUp(email: email, password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
        },
      );
      return const Right(null);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}
