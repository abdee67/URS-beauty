import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urs_beauty/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_bloc.dart';
import 'config/supabase_config.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.init();
  await SharedPreferences.getInstance().then((prefs) => prefs.clear());
  try {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    runApp(URSBEAUTY(showOnboarding: !hasSeenOnboarding));
  } catch (e) {
    runApp(URSBEAUTY(showOnboarding: true));
  }
}

class URSBEAUTY extends StatelessWidget {
  final bool showOnboarding;

  const URSBEAUTY({super.key, required this.showOnboarding});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(authRepo: AuthRepositoryImpl()),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'URS BEAUTY',
        darkTheme: ThemeData.dark().copyWith(
          appBarTheme: const AppBarTheme(
            backgroundColor: Color.fromARGB(235, 233, 30, 155),
            foregroundColor: Color.fromARGB(255, 255, 255, 255),

            elevation: 0,
          ),
        ),
        routerConfig: AppRouter(showOnboarding: showOnboarding).router,
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
