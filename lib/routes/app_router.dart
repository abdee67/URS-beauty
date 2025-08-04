import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:urs_beauty/features/auth/presentation/screens/forgotPassword.dart';
import 'package:urs_beauty/features/auth/presentation/screens/resetPassword.dart';
import 'package:urs_beauty/features/auth/presentation/screens/welcome_screen.dart';
import 'package:urs_beauty/features/auth/presentation/screens/login_screen.dart';
import 'package:urs_beauty/features/auth/presentation/screens/signup_screen.dart';
import 'package:urs_beauty/features/home/presentation/screens/home_screen.dart';

class AppRouter {
  final bool showOnboarding;
  AppRouter({required this.showOnboarding});

  GoRouter get router => GoRouter(
    initialLocation: showOnboarding ? '/welcome' : '/login',
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (_, __) => ResetPasswordScreen(),
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: ${state.error}')),
      );
    },
  );
}
