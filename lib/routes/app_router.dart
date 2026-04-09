import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:urs_beauty/core/constants/app_routes.dart';
import 'package:urs_beauty/features/auth/presentation/screens/forgotPassword.dart';
import 'package:urs_beauty/features/auth/presentation/screens/resetPassword.dart';
import 'package:urs_beauty/features/auth/presentation/screens/welcome_screen.dart';
import 'package:urs_beauty/features/auth/presentation/screens/login_screen.dart';
import 'package:urs_beauty/features/auth/presentation/screens/signup_screen.dart';
import 'package:urs_beauty/features/beauty_services/presentation/screens/service_list_screen.dart';
import 'package:urs_beauty/features/bookings/presentation/screens/booking_page.dart';
import 'package:urs_beauty/features/chat/presentation/screens/chat_screen.dart';
import 'package:urs_beauty/features/dashboard/dashboard_wrapper.dart';
import 'package:urs_beauty/features/home/presentation/pages/home_screen.dart';
import 'package:urs_beauty/features/payments/presentation/screens/payment_methods_screen.dart';
import 'package:urs_beauty/features/stylists/presentation/bloc/bloc/stylists_bloc.dart';
import 'package:urs_beauty/features/stylists/presentation/pages/stylist_detail_screen.dart';
import 'package:urs_beauty/features/stylists_location_finder/presentation/screens/location_screen.dart';
import 'package:urs_beauty/injection_container.dart';

class AppRouter {
  final bool showOnboarding;
  AppRouter({required this.showOnboarding});
  // Global navigator key is useful for specialized dialogs/snackbars
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: showOnboarding ? AppRoutes.onboardingScreen : AppRoutes.loginScreen,
    routes: [
      GoRoute(
        path: AppRoutes.onboardingScreen,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.loginScreen,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(path: AppRoutes.signupScreen, builder: (_, __) => const SignupScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return DashboardWrapper(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: AppRoutes.homeScreen, builder: (_, __) => const HomeScreen()),
            ],
          ),
          
          // Additional branches can be added here for other tabs
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.serviceScreen,
                builder: (_, __) => const ServiceListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.bookingScreen,
                builder: (_, __) => const BookingPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.stylistsScreen,
                builder: (_, state) {
                  final serviceId = state.uri.queryParameters['serviceId'];
                  final serviceName = _decodeParam(
                    state.uri.queryParameters['serviceName'],
                  );

                  return BlocProvider(
                    create: (_) {
                      final bloc = getit<StylistsBloc>();
                      if (serviceId?.trim().isNotEmpty == true) {
                        bloc.add(GetStylistsByServiceEvent(serviceId!));
                      } else {
                        bloc.add(const GetStylistsEvent());
                      }
                      return bloc;
                    },
                    child: StylistDetailScreen(
                      serviceId: serviceId,
                      serviceName: serviceName,
                    ),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: AppRoutes.chat, builder: (_, __) => const ChatScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.payment,
                builder: (_, __) => const PaymentMethodsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.forgotPasswordScreen,
        builder: (_, __) => ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPasswordScreen,
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

String? _decodeParam(String? value) {
  if (value == null) return null;
  try {
    return Uri.decodeComponent(value);
  } catch (_) {
    return value;
  }
}
