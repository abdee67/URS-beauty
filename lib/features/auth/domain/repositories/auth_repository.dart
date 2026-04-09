import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/auth/domain/entities/customer_address_input.dart';
import 'package:urs_beauty/features/auth/domain/entities/customer_address_entity.dart';
import 'package:urs_beauty/features/auth/domain/entities/customer_entity.dart';

abstract class AuthRepository {
Future <Either<Failures, void>> signUp(
  String email,
  String password,
  String firstName,
  String lastName,
  String phone,
  CustomerAddressInput address,
);
Future <Either<Failures, Session>> signIn(String email, String password);
Future<Either<Failures, void>> sendOtp(String email);
Future<Either<Failures, void>> verifyOtp(String email, String otp);
Future<Either<Failures, CustomerEntity>> getCurrentCustomer();
Future<Either<Failures, void>> signOut();
Future<Either<Failures, CustomerEntity>> updateCustomerProfile(CustomerEntity client);
Future<Either<Failures, void>> resetPassword(String email, String password);
Future<Either<Failures, void>> forgotPassword(String email);
Future<Either<Failures, CustomerAddressInput>> getCurrentLocationAddress();
Future<Either<Failures, CustomerAddressEntity>> createCustomerAddress(
  CustomerAddressInput input,
);

}
