import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/config/supabase_config.dart';
import '../../data/repositories/auth_repository_impl.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepositoryImpl authRepo;

  AuthBloc({required this.authRepo}) : super(AuthInitial()) {
    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await authRepo.signIn(event.email, event.password,);
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (session ){
          if(session.user.emailConfirmedAt != null) {
            emit(AuthSuccess());
          } else {
            SupabaseConfig.client.auth.signOut();
            emit(AuthFailure('Email not confirmed. Please verify your email.'));
          }
        }
      );
    });

on<SignUpRequested>((event, emit) async {
  emit(AuthLoading());
  final result = await authRepo.signUp(
     event.email,
     event.password,
     event.firstName,
     event.lastName,
     event.phone,
  );
  result.fold(
    (failure) => emit(AuthFailure(failure.message)),
    (_) => emit(AuthSuccess()), // 👈 custom state
  );
});
on<SendOtpRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await authRepo.sendOtp(event.email);
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (_) => emit(AuthSuccess()), // 👈 custom state
      );
    });

    on<VerifyOtpRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await authRepo.verifyOTP(event.email, event.otp);
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (_) => emit(AuthSuccess()),
      );
    });

  }
}
