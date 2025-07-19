import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/dependency_injection.dart';
import 'package:urs_beauty/features/service-listing/domain/use_cases/get_categories.dart';
import 'package:urs_beauty/features/service-listing/domain/use_cases/get_services.dart';
import 'package:urs_beauty/features/service-listing/domain/use_cases/toggle_favorite.dart';

import 'data/service_repo.dart';
import 'data/service_repo_impl.dart';
import 'presentation/cubit/service_list_cubit.dart';

class ServiceListingInjection {
  static Future<void> init() async {
    // Register repositories
    sl.registerLazySingleton<ServiceRepository>(
      () => ServiceRepositoryImpl(sl<SupabaseClient>()),
    );

    // Register use cases
    sl.registerLazySingleton(
      () => GetServices(sl<ServiceRepository>()),
    );
    sl.registerLazySingleton(
      () => GetCategories(sl<ServiceRepository>()),
    );
    sl.registerLazySingleton(
      () => ToggleFavorite(sl<ServiceRepository>()),
    );

    // Register cubit
    sl.registerFactory(
      () => ServiceListCubit(
        getServices: sl<GetServices>(),
        getCategories: sl<GetCategories>(),
        toggleFavorite: sl<ToggleFavorite>(),
      ),
    );
  }
}