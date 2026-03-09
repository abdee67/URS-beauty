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
import 'package:urs_beauty/features/home/data/dataSources/home_remote_data_source.dart';
import 'package:urs_beauty/features/home/data/repositories/home_repository_impl.dart';
import 'package:urs_beauty/features/home/domain/repositories/home_repository.dart';
import 'package:urs_beauty/features/home/domain/usecases/get_deals.dart';
import 'package:urs_beauty/features/home/domain/usecases/get_professionals.dart';
import 'package:urs_beauty/features/home/domain/usecases/get_services.dart';
import 'package:urs_beauty/features/home/presentation/bloc/home_bloc.dart';

final getit = GetIt.instance;
void initDependency(){
  // ===============injectin auth use case=================
   getit.registerLazySingleton(() => SignIn(getit()));
   getit.registerLazySingleton(() => SignUp(getit()));
   getit.registerLazySingleton(() => SignOut(getit()));
   getit.registerLazySingleton(() => SendOtp(getit()));
   getit.registerLazySingleton(() => VerifyOTP(getit()));
   getit.registerLazySingleton(() => ForgotPassword(getit()));
   getit.registerLazySingleton(() => ResetPassword(getit()));
   getit.registerLazySingleton(() => GetCurrentClient(getit()));
   getit.registerLazySingleton(() => UpdateClientProfile(getit()));


   // ===========injectin auth bloc=================
   getit.registerFactory(() => AuthBloc( getit(), getit(), getit(), getit(), getit(), getit(), getit(), getit(), getit()));

 
  // injecting auth repository===================
   getit.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getit()));

   //injecting auth data source===================
   getit.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl());

   // ===============injectin home use case=================
   getit.registerLazySingleton(() => GetProfessionals(getit()));
   getit.registerLazySingleton(() => GetServices(getit()));
   getit.registerLazySingleton(() => GetDeals(getit()));

   // injectin home data source===================
   getit.registerLazySingleton<HomeRemoteDataSource>(() => HomeRemoteDataSource());
 
  // ===========injectin home repository=================
    getit.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(remoteDataSource:getit()));

    //injectin home bloc===================
    getit.registerFactory(() => HomeBloc(getDeals:getit(), getProfessionals:getit(), getServices:getit()));

   //
}