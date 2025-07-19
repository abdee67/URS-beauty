import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  });
  
  Future<void> signInWithEmail({
    required String email,
    required String password,
  });
  
  Future<void> signOut();
  User? get currentUser;
  Stream<User?> get userChanges;
}