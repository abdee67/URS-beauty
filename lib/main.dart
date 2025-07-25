import 'dart:async';

import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'config/supabase_config.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.init();
  runApp(const URSBEAUTY());
}

class URSBEAUTY extends StatefulWidget {
  const URSBEAUTY({super.key});

  @override
  State<URSBEAUTY> createState() => _URSBEAUTYState();
}

class _URSBEAUTYState extends State<URSBEAUTY> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }

    _linkSubscription = _appLinks.uriLinkStream.listen(_handleDeepLink);
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Received deep link: $uri');
     if (uri.scheme == 'ursbeauty') {
     if (uri.host == 'login') {
      final code = uri.queryParameters['code'];
      if (code != null) {
        debugPrint('Login code detected: $code');
        AppRouter.router.go('/login?code=$code');
        return;
      }
    }
   
      if (  uri.fragment.isNotEmpty){
      final params = Uri.splitQueryString(uri.fragment);
      final refreshToken = params['refresh_token'];

      if ( refreshToken != null) {
        debugPrint('Email verification link detected');
        _handleEmailVerification( refreshToken);
        return;
      }
    }
  }
  debugPrint('Unhandled deep link: $uri');
  }

  Future<void> _handleEmailVerification( String refreshToken) async {
    try {
      await SupabaseConfig.client.auth.setSession(refreshToken);
      debugPrint('Email verification successful');
      AppRouter.router.go('/home');
    } catch (e) {
      debugPrint('Email verification failed: $e');
      AppRouter.router.go('/login?error=verification_failed');
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'URS BEAUTY',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      routerConfig: AppRouter.router,
    );
  }
}