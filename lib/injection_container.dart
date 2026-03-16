import 'package:get_it/get_it.dart';
import 'package:urs_beauty/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:urs_beauty/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:urs_beauty/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:urs_beauty/features/auth/domain/repositories/auth_repository.dart';
import 'package:urs_beauty/features/auth/domain/usecases/forgot_password.dart';
import 'package:urs_beauty/features/auth/domain/usecases/get_current_client.dart';
import 'package:urs_beauty/features/auth/domain/usecases/reset_password.dart';
import 'package:urs_beauty/features/auth/domain/usecases/send_otp.dart';
import 'package:urs_beauty/features/auth/domain/usecases/sign_in.dart';
import 'package:urs_beauty/features/auth/domain/usecases/sign_out.dart';
import 'package:urs_beauty/features/auth/domain/usecases/sign_up.dart';
import 'package:urs_beauty/features/auth/domain/usecases/update_client_profile.dart';
import 'package:urs_beauty/features/auth/domain/usecases/verify_otp.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:urs_beauty/features/beauty_services/data/datasources/service_categories_remote_data_source.dart';
import 'package:urs_beauty/features/beauty_services/data/datasources/service_categories_remote_data_source_impl.dart';
import 'package:urs_beauty/features/beauty_services/data/repositories/service_categories_repository_impl.dart';
import 'package:urs_beauty/features/beauty_services/domain/repositories/service_categories_repository.dart';
import 'package:urs_beauty/features/beauty_services/domain/usecases/get_service_categories.dart';
import 'package:urs_beauty/features/deals/data/datasource/deals_remote_data_source.dart';
import 'package:urs_beauty/features/deals/data/datasource/deals_remote_data_source_impl.dart';
import 'package:urs_beauty/features/deals/data/repository/deals_repository_impl.dart';
import 'package:urs_beauty/features/deals/domain/repository/deals_repository.dart';
import 'package:urs_beauty/features/deals/domain/usescases/get_deals.dart';
import 'package:urs_beauty/features/professionals/data/datasources/professionals_remote_data_source.dart';
import 'package:urs_beauty/features/professionals/data/datasources/professionals_remote_datasource_impl.dart';
import 'package:urs_beauty/features/professionals/data/repository/professionals_repository_impl.dart';
import 'package:urs_beauty/features/professionals/domain/repository/professionals_repository.dart';
import 'package:urs_beauty/features/professionals/domain/usecases/get_professionals.dart';
import 'package:urs_beauty/features/home/presentation/bloc/home_bloc.dart';

final getit = GetIt.instance;
void initDependency(){

  //==================injecting auth data source===================
   getit.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl());
   getit.registerLazySingleton<ServiceCategoriesRemoteDataSource>(() => ServiceCategoriesRemoteDataSourceImpl());
    getit.registerLazySingleton<ProfessionalsRemoteDataSource>(() => ProfessionalsRemoteDataSourceImpl());
    getit.registerLazySingleton<DealsRemoteDataSource>(() => DealsRemoteDataSourceImpl());
     //================== injecting  repository===================
   getit.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getit()));
   getit.registerLazySingleton <ServiceCategoriesRepository>(() => ServiceCategoriesRepositoryImpl(remoteDataSource: getit()));
   getit.registerLazySingleton<ProfessionalsRepository>(() => ProfessionalsRepositoryImpl(remoteDataSource: getit()));
   getit.registerLazySingleton<DealsRepository>(() => DealsRepositoryImpl(remoteDataSource: getit()));


  // ===============injectin use case=================
  // Auth use cases
   getit.registerLazySingleton(() => SignIn(getit()));
   getit.registerLazySingleton(() => SignUp(getit()));
   getit.registerLazySingleton(() => SignOut(getit()));
   getit.registerLazySingleton(() => SendOtp(getit()));
   getit.registerLazySingleton(() => VerifyOTP(getit()));
   getit.registerLazySingleton(() => ForgotPassword(getit()));
   getit.registerLazySingleton(() => ResetPassword(getit()));
   getit.registerLazySingleton(() => GetCurrentClient(getit()));
   getit.registerLazySingleton(() => UpdateClientProfile(getit()));

    // Home use cases
   getit.registerLazySingleton(() => GetProfessionals(getit()));
   getit.registerLazySingleton(() => GetServiceCategory(getit()));
   getit.registerLazySingleton(() => GetDeals(getit()));


   // ===========injectin bloc=================
   getit.registerFactory(() => AuthBloc( getit(), getit(), getit(), getit(), getit(), getit(), getit(), getit(), getit()));
    getit.registerFactory(() => HomeBloc(getDeals:getit(), getProfessionals:getit(), getServices:getit()));

 


   
   

 


   //
}