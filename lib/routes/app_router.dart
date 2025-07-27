import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:urs_beauty/features/auth/presentation/screens/welcome_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';

class AppRouter {
  final bool showOnboarding;
   AppRouter({required this.showOnboarding});
  
  GoRouter get router => GoRouter(
    initialLocation: showOnboarding ? '/welcome' : '/login',
    routes: [
      GoRoute(
        path: '/welcome',
        pageBuilder: (context, state) => MaterialPage(
          child: OnboardingScreen(),
        ),
      ),
      GoRoute(path: '/login', name:'login', pageBuilder: (context, state) {
        final code = state.uri.queryParameters['code'];
        return MaterialPage(
        child: LoginScreen(verificationCode: code),
        );
        }
        ),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: ${state.error}')),
      );
    },
  );
}
