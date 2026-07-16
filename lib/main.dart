import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/core/constants/app_routes.dart';
import 'package:urs_beauty/core/utils/session_expiry_policy.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:urs_beauty/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:urs_beauty/features/home/presentation/bloc/home_bloc.dart';
import 'package:urs_beauty/injection_container.dart';
import 'config/supabase_config.dart';
import 'routes/app_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  await SupabaseConfig.init();
  Stripe.urlScheme = 'ursbeauty';
  final merchantIdentifier = dotenv.env['STRIPE_MERCHANT_IDENTIFIER'];
  if (merchantIdentifier != null && merchantIdentifier.trim().isNotEmpty) {
    Stripe.merchantIdentifier = merchantIdentifier.trim();
  }
  // ONLY initialize Stripe on mobile and web platforms
  if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
    Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;
    await Stripe.instance.applySettings();
  } else {
    debugPrint(
      "Stripe is not initialized: Desktop platforms are not natively supported.",
    );
  }
  initDependency(); //initializing getit for dependency injection
  runApp(const URSBEAUTY());
}

class URSBEAUTY extends StatefulWidget {
  const URSBEAUTY({super.key});
  @override
  State<URSBEAUTY> createState() => _URSBEAUTYState();
}

class _URSBEAUTYState extends State<URSBEAUTY>
    with WidgetsBindingObserver {
  bool showOnboarding = true;
  bool isLoading = true;
  late GoRouter _router;
  bool _routerReady = false;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listenForForcedLogout();
    _checkOnboardingStatus();

    ///this suppose to be in splash screen but for now i will put it here to avoid creating another screen just for this purpose
  }

  /// Redirect to the login screen whenever the user becomes signed out, whether
  /// that was a manual sign-out or the client-side expiry policy calling
  /// [SupabaseClient.auth.signOut]. Signing out wipes the local session storage,
  /// so there is nothing to auto-log-in with on the next launch.
  void _listenForForcedLogout() {
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        if (data.event == AuthChangeEvent.signedOut && _routerReady) {
          _router.go(AppRoutes.loginScreen);
        }
      },
      onError: (Object error) {
        // gotrue pushes token-refresh failures onto this stream (e.g.
        // AuthRetryableFetchException when the network is flaky as the app
        // resumes). Without an onError handler these become unhandled
        // exceptions that crash the app. They are transient and gotrue retries
        // on its own, so keep the session and just log in debug.
        if (kDebugMode) {
          debugPrint('Auth state stream error (ignored): $error');
        }
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // Left the foreground: stamp the time so we can measure the gap on wake.
        unawaited(SessionExpiryPolicy.markBackgrounded());
        break;
      case AppLifecycleState.resumed:
        // Back in the foreground: enforce the login wall if we were away too
        // long. Active users never reach here mid-use, so they are untouched.
        unawaited(_enforceSessionExpiry());
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  Future<void> _enforceSessionExpiry() async {
    final auth = Supabase.instance.client.auth;
    final expired = await SessionExpiryPolicy.hasExpiredWhileBackgrounded();
    await SessionExpiryPolicy.clear();
    if (expired && auth.currentSession != null) {
      // Local scope clears secure storage and emits signedOut without a network
      // call, so it works even on a flaky connection after a long background.
      // The onAuthStateChange listener turns signedOut into a login redirect.
      try {
        await auth.signOut(scope: SignOutScope.local);
      } catch (_) {
        // Never let a forced logout crash the resume path.
      }
    }
  }


  Future<void> _checkOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
      setState(() {
        showOnboarding = !hasSeenOnboarding;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        showOnboarding = true;
        isLoading = false;
      });
    }

    // Initialize router after onboarding status is determined
    _router = AppRouter(showOnboarding: showOnboarding).router;
    _routerReady = true;
  }
  
  @override
  void dispose() {
    _authSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return MultiProvider(
      providers: [
        // Bloc providers
        BlocProvider(create: (context) => getit<AuthBloc>()),
        BlocProvider(create: (context) => getit<HomeBloc>()),
        BlocProvider(create: (context) => getit<BookingBloc>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'URS BEAUTY',
        routerConfig: _router,
        theme: ThemeData(
          primarySwatch: Colors.pink,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }
}
