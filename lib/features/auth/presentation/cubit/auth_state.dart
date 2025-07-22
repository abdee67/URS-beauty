import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? errorMessage;
  final User? user;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.user,
  });
  factory AuthState.initial() {
    return const AuthState();
  }
  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    User? user,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
    );
  }
@override
  List<Object?> get props => [status, errorMessage, user];
}