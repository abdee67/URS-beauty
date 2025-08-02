import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urs_beauty/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:urs_beauty/features/home/data/dataSources/home_remote_data_source.dart';
import 'package:urs_beauty/features/home/data/repositories/home_repository_impl.dart';
import 'package:urs_beauty/features/home/domain/usecases/get_professionals.dart';
import 'package:urs_beauty/features/home/domain/usecases/get_services.dart';
import 'package:urs_beauty/features/home/domain/usecases/get_deals.dart';
import 'package:urs_beauty/injection_container.dart';
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
    return MultiProvider(
      providers: [
        // Bloc providers
        BlocProvider(
          create: (context) => AuthBloc(authRepo: AuthRepositoryImpl()),
        ),
        // Use case providers
        Provider(create: (_) => GetProfessionals(HomeRepositoryImpl(remoteDataSource: HomeRemoteDataSource()))),
        Provider(create: (_) => GetServices(HomeRepositoryImpl(remoteDataSource: HomeRemoteDataSource()))),
        Provider(create: (_) => GetDeals(HomeRepositoryImpl(remoteDataSource: HomeRemoteDataSource()))),
        Provider(create: (_) => HomeRepositoryImpl(remoteDataSource: HomeRemoteDataSource())), // Repository
        Provider(create: (_) => HomeRemoteDataSource()),
        
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'URS BEAUTY',
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
