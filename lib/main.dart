import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/dependency_injection.dart';
import 'package:urs_beauty/features/auth/data/auth_repo.dart';
import 'package:urs_beauty/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:urs_beauty/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:urs_beauty/main_app_screen.dart';


import 'features/service-listing/service_listing_injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ihoumeuczixerqaybris.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlob3VtZXVjeml4ZXJxYXlicmlzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI1OTgxMjMsImV4cCI6MjA2ODE3NDEyM30.A8432hudc8fk0AW_70_IZMGM_wiqFgCqf2sikN3C7Fg',
  );
    // Initialize dependency injection
  await initDependencies();
  await ServiceListingInjection.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'URS Beauty',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => sl<AuthCubit>(),
        child: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: sl<AuthRepository>().userChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        final user = snapshot.data;
        if (user != null) {
          return const MainAppScreen();
        }
        return const SignInScreen();
      },
    );
  }
}