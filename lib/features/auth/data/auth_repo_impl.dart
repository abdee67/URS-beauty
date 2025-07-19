import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/features/auth/data/auth_repo.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;
  final GoTrueClient _auth;

  AuthRepositoryImpl(this._supabase) : _auth = _supabase.auth;

  @override
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    final response = await _auth.signUp(
      email: email,
      password: password,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'email': email,
      },
    );
    
    if (response.user == null) {
      throw Exception('Sign up failed');
    }
    
    // Create customer profile
    await _supabase.from('customers').insert({
      'user_id': response.user!.id,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phone,
      'email': email,
    });
  }

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _auth.signInWithPassword(
      email: email,
      password: password,
    );
    
    if (response.user == null) {
      throw Exception('Sign in failed');
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Stream<User?> get userChanges => _auth.onAuthStateChange.map((event) => event.session?.user);
}