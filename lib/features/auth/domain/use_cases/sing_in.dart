import 'package:urs_beauty/features/auth/data/auth_repo.dart';

class SignIn {
  final AuthRepository _repository;

  SignIn(this._repository);

  Future<void> execute(String email, String password) async {
    await _repository.signInWithEmail(email: email, password: password);
  }
}