abstract class AuthState {}

class EmailVerificationSent extends AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class OtpSent extends AuthState {}

class OtpVerified extends AuthState {}

class ForgotPasswordSent extends AuthState {}

class ResetPasswordSent extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}
