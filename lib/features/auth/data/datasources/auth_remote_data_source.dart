 import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/auth/data/models/client_model.dart';

abstract class AuthRemoteDataSource {

Future <void> signUp(String email, String password, String firstName, String lastName, int phone);
Future <Session> signIn(String email, String password);
Future<void> sendOtp(String email);
Future<void> verifyOTP(String email, String otp);
Future<ClientModel> getCurrentClient();
Future< void> signOut();
Future< ClientModel> updateClientProfile(ClientModel client);
Future< void> resetPassword(String email, String password);
Future<void> forgotPassword(String email);
}