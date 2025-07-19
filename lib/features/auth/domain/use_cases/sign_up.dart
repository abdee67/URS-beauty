import 'package:urs_beauty/features/auth/data/auth_repo.dart';

class SignUp {
  final AuthRepository _repository;

  SignUp(this._repository);

  Future<void> execute({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    await _repository.signUpWithEmail(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
    );
  }
}