import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/screens/sign_up_screen.dart';
import 'package:urs_beauty/screens/login_screen.dart';
import 'package:urs_beauty/screens/otpverificatioN.dart';
import 'package:urs_beauty/screens/home_screen.dart';

import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ihoumeuczixerqaybris.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlob3VtZXVjeml4ZXJxYXlicmlzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI1OTgxMjMsImV4cCI6MjA2ODE3NDEyM30.A8432hudc8fk0AW_70_IZMGM_wiqFgCqf2sikN3C7Fg',
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  void _initDeepLinkListener() async {
    _sub = AppLinks().uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          print('Deep link received: $uri');

          if (uri.path.contains('access_token')) {
            // You can check query params or fragment too
            Navigator.pushReplacementNamed(context, '/login');
          }
        }
      },
      onError: (err) {
        print('Link error: $err');
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'URS BEAUTY',
      initialRoute: '/login',
      routes: {
        '/signup': (_) => SignupScreen(),
        '/login': (_) => LoginScreen(),
        '/phoneOtp': (_) => OtpVerificationScreen(phone: ''),
        '/home': (_) => HomeScreen(),
      },
    );
  }
}
