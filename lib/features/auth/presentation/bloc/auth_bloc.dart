import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/features/auth/domain/usecases/forgot_password.dart';
import 'package:urs_beauty/features/auth/domain/usecases/get_current_client.dart';
import 'package:urs_beauty/features/auth/domain/usecases/reset_password.dart';
import 'package:urs_beauty/features/auth/domain/usecases/send_otp.dart';
import 'package:urs_beauty/features/auth/domain/usecases/sign_in.dart';
import 'package:urs_beauty/features/auth/domain/usecases/sign_out.dart';
import 'package:urs_beauty/features/auth/domain/usecases/sign_up.dart';
import 'package:urs_beauty/features/auth/domain/usecases/update_client_profile.dart';
import 'package:urs_beauty/features/auth/domain/usecases/verify_otp.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignIn signIn;
  final SignOut signOut;
  final SignUp signUp;
  final SendOtp sendOtp;
  final VerifyOTP verifyOTP;
  final GetCurrentClient getCurrentClient;
  final UpdateClientProfile updateClientProfile;
  final ForgotPassword forgotPassword;
  final ResetPassword resetPassword;
  AuthBloc( this.signIn, this.signOut, this.signUp, this.sendOtp, this.verifyOTP, this.getCurrentClient, this.updateClientProfile, this.forgotPassword, this.resetPassword) : super(AuthInitial()) {
    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await signIn(event.email, event.password,);
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
      (_)  =>  emit(AuthSuccess()),
      );
      });


    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await signUp(
        event.email,
        event.password,
        event.firstName,
        event.lastName,
        event.phone,
      );
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (_) => emit(EmailVerificationSent()),
      );
    });
    on<SendOtpRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await sendOtp(event.email);
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (_) => emit(OtpSent()),
      );
    });

    on<VerifyOtpRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await verifyOTP(event.email, event.otp);
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (_) => emit(OtpVerified()),
      );
    });
    on<ForgotPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await forgotPassword(event.email);
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (_) => emit(ForgotPasswordSent()),
      );
    });
    on<ResetPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await resetPassword(event.email, event.password);
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (_) => emit(ResetPasswordSent()),
      );
    });
  }
}
