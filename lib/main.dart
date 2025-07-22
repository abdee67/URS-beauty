import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'config/supabase_config.dart';
import 'routes/app_router.dart';
import 'package:app_links/app_links.dart';


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
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    initDeepLinks(); 
    // Handle any initial deep link
    // Additional initialization if needed
  }

  Future<void> initDeepLinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      debugPrint('Initial deep link: $initialUri');
      if (initialUri != null) {
        handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('Error getting initial deep link: $e');
    }

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      handleDeepLink(uri);
    }, onError: (err) {
      debugPrint('Error listening to deep links: $err');
    });
  }
  void handleDeepLink(Uri uri) {
    debugPrint('Received deep link: $uri');
    if (uri.pathSegments.contains('verify')) {
      final code = uri.queryParameters['code'];
      if (code != null) {
        context.push('/verify?code=$code');
      } else {
        debugPrint('No verification code found in deep link');
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'URS BEAUTY',
      theme: ThemeData.light(),
      routerConfig: AppRouter.router,
      darkTheme: ThemeData.dark(),
    );
    
  }
  
}
