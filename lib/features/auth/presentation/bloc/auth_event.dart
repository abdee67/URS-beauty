abstract class AuthEvent {}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  SignInRequested(this.email, this.password);
}

class SignUpRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String password;

  SignUpRequested(
    this.email,
    this.password,
    this.firstName,
    this.lastName,
    this.phone,
  );
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
