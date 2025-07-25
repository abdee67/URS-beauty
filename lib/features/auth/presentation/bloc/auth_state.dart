abstract class AuthState {}
class EmailVerificationSent extends AuthState {}


class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String message;
  AuthSuccess(this.message);
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}
