import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/dependency_injection.dart';
import 'package:urs_beauty/features/auth/data/auth_repo.dart';
import 'package:urs_beauty/features/auth/data/auth_repo_impl.dart';
import 'package:urs_beauty/features/auth/domain/use_cases/sign_out.dart';
import 'package:urs_beauty/features/auth/domain/use_cases/sign_up.dart';
import 'package:urs_beauty/features/auth/domain/use_cases/sing_in.dart';
import 'package:urs_beauty/features/auth/presentation/cubit/auth_cubit.dart';

class AuthInjection {
  static Future<void> init() async {
    // Register repository
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<SupabaseClient>()),
    );

    // Register use cases
    sl.registerLazySingleton(
      () => SignIn(sl<AuthRepository>()),
    );
    sl.registerLazySingleton(
      () => SignUp(sl<AuthRepository>()),
    );
    sl.registerLazySingleton(
      () => SignOut(sl<AuthRepository>()),
    );

    // Register cubit
    sl.registerFactory(
      () => AuthCubit(
        signIn: sl<SignIn>(),
        signUp: sl<SignUp>(),
        signOut: sl<SignOut>(),
      ),
    );
  }
}