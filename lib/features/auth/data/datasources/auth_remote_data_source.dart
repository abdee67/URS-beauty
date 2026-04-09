import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/features/auth/data/models/customer_model.dart';
import 'package:urs_beauty/features/auth/data/models/customer_address_model.dart';
import 'package:urs_beauty/features/auth/domain/entities/customer_address_input.dart';

abstract class AuthRemoteDataSource {

Future <void> signUp(
  String email,
  String password,
  String firstName,
  String lastName,
  String phone,
  CustomerAddressInput address,
);
Future <Session> signIn(String email, String password);
Future<void> sendOtp(String email);
Future<void> verifyOTP(String email, String otp);
Future<CustomerModel> getCurrentCustomer();
Future< void> signOut();
Future< CustomerModel> updateCustomerProfile(CustomerModel client);
Future< void> resetPassword(String email, String password);
Future<void> forgotPassword(String email);
  
  Future<CustomerAddressModel> createCustomerAddress(Map<String, dynamic> payload);
}
