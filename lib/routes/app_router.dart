import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:urs_beauty/features/auth/presentation/screens/email_verification_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text('Error: ${state.error}'),
        ),
      );
    },
  );
}
