import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:urs_beauty/features/auth/presentation/screens/forgotPassword.dart';
import 'package:urs_beauty/features/auth/presentation/screens/resetPassword.dart';
import 'package:urs_beauty/features/auth/presentation/screens/welcome_screen.dart';
import 'package:urs_beauty/features/auth/presentation/screens/login_screen.dart';
import 'package:urs_beauty/features/auth/presentation/screens/signup_screen.dart';
import 'package:urs_beauty/features/bookings/presentation/screens/booking_page.dart';
import 'package:urs_beauty/features/chat/presentation/screens/chat_screen.dart';
import 'package:urs_beauty/features/dashboard/dashboard_wrapper.dart';
import 'package:urs_beauty/features/home/presentation/pages/home_screen.dart';
import 'package:urs_beauty/features/payments/presentation/screens/payment_methods_screen.dart';
import 'package:urs_beauty/features/stylists/presentation/pages/stylist_detail_screen.dart';
import 'package:urs_beauty/features/stylists_location_finder/presentation/screens/location_screen.dart';

class AppRouter {
  final bool showOnboarding;
  AppRouter({required this.showOnboarding});
  // Global navigator key is useful for specialized dialogs/snackbars
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return DashboardWrapper(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
            ],
          ),
          // Additional branches can be added here for other tabs
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/location',
                builder: (_, __) => const LocationScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/booking', builder: (_, __) => const BookingPage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stylists',
                builder: (_, __) => const StylistDetailScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/chat', builder: (_, __) => const ChatScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/payment', builder: (_, __) => const PaymentMethodsScreen()),
            ],
          ),
        ],
      ),
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
