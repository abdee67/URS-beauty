import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/features/auth/auth_injection.dart';
import 'package:get_it/get_it.dart';
import 'package:urs_beauty/features/service-listing/service_listing_injection.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Register Supabase client
  sl.registerSingleton<SupabaseClient>(
    SupabaseClient(
      'YOUR_SUPABASE_URL',
      'YOUR_SUPABASE_ANON_KEY',
    ),
  );

  // Initialize other injections
  await AuthInjection.init();
  await ServiceListingInjection.init();
}