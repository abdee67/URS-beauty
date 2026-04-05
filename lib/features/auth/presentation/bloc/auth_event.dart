import 'package:urs_beauty/features/auth/domain/entities/customer_address_input.dart';

abstract class AuthEvent {}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  SignInRequested(this.email, this.password);
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String phone;
  final CustomerAddressInput address;

  SignUpRequested({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.address,
  });
}

class SendOtpRequested extends AuthEvent {
  final String email;

  SendOtpRequested(this.email);
}

class VerifyOtpRequested extends AuthEvent {
  final String email;
  final String otp;

  VerifyOtpRequested(this.email, this.otp);
}
class ForgotPasswordRequested extends AuthEvent {
  final String email;

  ForgotPasswordRequested(this.email);
}
class ResetPasswordRequested extends AuthEvent {
  final String email;
  final String password;

  ResetPasswordRequested(this.email, this.password);
}


