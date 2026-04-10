import 'package:urs_beauty/features/auth/domain/entities/customer_address_input.dart';

abstract class AuthState {}

class EmailVerificationSent extends AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAddressLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthLoggedOut extends AuthState {}

class OtpSent extends AuthState {}

class OtpVerified extends AuthState {}

class ForgotPasswordSent extends AuthState {}

class ResetPasswordSent extends AuthState {}

class AuthAddressAutofilled extends AuthState {
  final CustomerAddressInput address;
  AuthAddressAutofilled(this.address);
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}
