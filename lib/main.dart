import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urs_beauty/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:urs_beauty/features/home/data/dataSources/home_remote_data_source.dart';
import 'package:urs_beauty/features/home/data/repositories/home_repository_impl.dart';
import 'package:urs_beauty/features/home/domain/usecases/get_professionals.dart';
import 'package:urs_beauty/features/home/domain/usecases/get_services.dart';
import 'package:urs_beauty/features/home/domain/usecases/get_deals.dart';
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
  bool showOnboarding = true;
  bool isLoading = true;
  late GoRouter _router;

  // Create singletons for dependency injection
  late final HomeRemoteDataSource _homeRemoteDataSource;
  late final HomeRepositoryImpl _homeRepository;
  late final GetProfessionals _getProfessionals;
  late final GetServices _getServices;
  late final GetDeals _getDeals;

  @override
  void initState() {
    super.initState();
    _initializeDependencies();
    _checkOnboardingStatus();
  }

  void _initializeDependencies() {
    _homeRemoteDataSource = HomeRemoteDataSource();
    _homeRepository = HomeRepositoryImpl(
      remoteDataSource: _homeRemoteDataSource,
    );
    _getProfessionals = GetProfessionals(_homeRepository);
    _getServices = GetServices(_homeRepository);
    _getDeals = GetDeals(_homeRepository);
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
        BlocProvider(
          create: (context) => AuthBloc(authRepo: AuthRepositoryImpl()),
        ),
        // Use case providers - using singleton instances
        Provider.value(value: _getProfessionals),
        Provider.value(value: _getServices),
        Provider.value(value: _getDeals),
        Provider.value(value: _homeRepository),
        Provider.value(value: _homeRemoteDataSource),
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
