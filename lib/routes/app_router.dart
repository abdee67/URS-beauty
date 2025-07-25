import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';

class AppRouter {
  static final router = GoRouter(
    navigatorKey: GlobalKey<NavigatorState>(),
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', name:'login', builder: (context, state) {
        final code = state.uri.queryParameters['code'];
        return LoginScreen(code: code); }),
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
