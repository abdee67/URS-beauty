import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/core/errors/error_handler.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/auth/data/datasources/auth_location_data_source.dart';
import 'package:urs_beauty/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:urs_beauty/features/auth/data/models/customer_model.dart';
import 'package:urs_beauty/features/auth/data/models/customer_address_model.dart';
import 'package:urs_beauty/features/auth/domain/entities/customer_address_input.dart';
import 'package:urs_beauty/features/auth/domain/entities/customer_entity.dart';
import 'package:urs_beauty/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocationDataSource locationDataSource;
  AuthRepositoryImpl(this.remoteDataSource, this.locationDataSource);
  @override
  Future<Either<Failures, Session>> signIn(
    String email,
    String password,
  ) async {
    return repoErrorHnadler(() async {
      // Attempt to sign in with email and password
      final result = await remoteDataSource.signIn(email, password);
      return result;
    });
  }

  @override
  Future<Either<Failures, void>> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
    String phone,
    CustomerAddressInput address,
  ) async {
    return repoErrorHnadler(() async {
      final signup = await remoteDataSource.signUp(
        email,
        password,
        firstName,
        lastName,
        phone,
        address,
      );
      return signup;
    });
  }

  @override
  Future<Either<Failures, void>> sendOtp(String email) async {
    return repoErrorHnadler(() async {
      // Try resend first (for existing users)
      return await remoteDataSource.sendOtp(email);
    });
  }

  @override
  Future<Either<Failures, void>> verifyOtp(String email, String otp) async {
    return repoErrorHnadler(() async {
      return await remoteDataSource.verifyOTP(email, otp);
    });
  }

  @override
  Future<Either<Failures, void>> signOut() async {
    return repoErrorHnadler(() async {
      final signout = await remoteDataSource.signOut();
      return signout;
    });
  }

  @override
  Future<Either<Failures, CustomerEntity>> getCurrentCustomer() async {
    return repoErrorHnadler(() async {
      final user = await remoteDataSource.getCurrentCustomer();
      return user.toEntity();
    });
  }

  @override
  Future<Either<Failures, CustomerEntity>> updateCustomerProfile(
    CustomerEntity client,
  ) async {
    return repoErrorHnadler(() async {
      final clientModel = CustomerModel(
        id: client.id,
        email: client.email,
        firstName: client.firstName,
        lastName: client.lastName,
        phone: client.phone,
      );
      final update = await remoteDataSource.updateCustomerProfile(clientModel);
      return update;
    });
  }

  @override
  Future<Either<Failures, void>> forgotPassword(String email) async {
    return repoErrorHnadler(() async {
      final forgotPassword = await remoteDataSource.forgotPassword(email);
      return forgotPassword;
    });
  }

  @override
  Future<Either<Failures, void>> resetPassword(
    String email,
    String password,
  ) async {
    return repoErrorHnadler(() async {
      final reset = await remoteDataSource.resetPassword(email, password);
      return reset;
    });
  }

  @override
  Future<Either<Failures, CustomerAddressInput>>
  getCurrentLocationAddress() async {
    return repoErrorHnadler(() async {
      final address = await locationDataSource.getCurrentLocationAddress();
      return address;
    });
  }

  @override
  Future<Either<Failures, CustomerAddressModel>> createCustomerAddress(
    CustomerAddressInput input,
  ) async {
    return repoErrorHnadler(() async {
      final saved = await remoteDataSource.createCustomerAddress(
        input.toJson(),
      );
      return saved;
    });
  }

  @override
  Future<Either<Failures, String>> checkStartupSession() async {
    return repoErrorHnadler(() async {
      final status = await remoteDataSource.checkStartupSession();
      return status;
    });
  }
}
