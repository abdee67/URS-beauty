import 'package:urs_beauty/features/auth/data/auth_repo.dart';

class SignOut {
  final AuthRepository _repository;

  SignOut(this._repository);

  Future<void> execute() async {
    await _repository.signOut();
  }
}