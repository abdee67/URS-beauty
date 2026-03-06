import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/config/supabase_config.dart';
import 'package:urs_beauty/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:urs_beauty/features/auth/data/models/client_model.dart';

abstract class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
    Future<Session> signIn(
    String email,
    String password,
  ) async {
    try {
      // Attempt to sign in with email and password
      final result = await SupabaseConfig.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (result.session == null) {
        throw Exception('Failed to sign in: No session returned');
      }
      return (result.session!);
    } catch (e) {
      return throw Exception('Failed to sign in: ${e.toString()}');
    }
  }
 
  @override
  Future<void> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
    int phone,
  ) async {
    try {
      final result =  await SupabaseConfig.client.auth.signUp(
        email: email,
        password: password,
        data: {'first_name': firstName, 'last_name': lastName, 'phone': phone},
        emailRedirectTo: 'ursbeauty://login/', // for deep linking
      );
      if (result.user == null) {
        throw Exception('Failed to sign up: No user returned');
      }
      return;
    } catch (e) {
       throw Exception('Failed to sign up: ${e.toString()}');
    }
  }
  
  @override
  Future< void> sendOtp(String email) async {
    try {
      // Try resend first (for existing users)
   final result = await SupabaseConfig.client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      if (result.messageId == null) {
        throw Exception('Failed to resend OTP: No message ID returned');
      }
      return;
    } catch (e) {
      // If resend fails, try signInWithOtp (for new users)
      try {
        await SupabaseConfig.client.auth.signInWithOtp(
          email: email,
          shouldCreateUser: true,
        );
        return;
      } catch (otpError) {
        throw Exception('Failed to send OTP: ${otpError.toString()}');
      } 
    }
  }
  @override
  Future<void> verifyOTP(String email, String otp) async {
    try {
     final result =  await SupabaseConfig.client.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.email,
      );
      if (result.session == null) {
        throw Exception('Failed to verify OTP: No session returned');
      }
      return ;
    } catch (e) {
      throw Exception('Failed to verify OTP: ${e.toString()}');
    }
  }
  @override
  Future<void> signOut() async {
    try {
      await SupabaseConfig.client.auth.signOut();
      return ;
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }
 @override
  Future<ClientModel> getCurrentClient() async {
    try {
      final user = SupabaseConfig.client.auth.currentUser;
      final client = ClientModel(
        id: user!.id,
        email: user.email!,
        firstName: user.userMetadata?['first_name'] ?? '',
        lastName: user.userMetadata?['last_name'] ?? '',
        phone: int.parse(user.userMetadata?['phone'] ?? '0'),
      );
      if (client.id.isEmpty || client.email.isEmpty) {
        throw Exception('User data is incomplete');
      } 
      return client;

    } catch (e) {
      throw Exception('Failed to retrieve client information');
    }
  }
  @override 
  Future<ClientModel> updateClientProfile(ClientModel client) async {
    try {
      await SupabaseConfig.client.auth.updateUser(
        UserAttributes(
          email: client.email,
          data: {
            'first_name': client.firstName,
            'last_name': client.lastName,
            'phone': client.phone.toString(),
          },
        ),
      );
      final clinet = ClientModel(
        id: client.id,
        email: client.email,
        firstName: client.firstName,
        lastName: client.lastName,
        phone: client.phone,
        );
        if (clinet.id.isEmpty || clinet.email.isEmpty) {
          throw Exception('Updated user data is incomplete');
        }
      return clinet;
    } catch (e) {
      return throw Exception('Failed to update client profile');
    }
  }
  @override
  Future<void> forgotPassword(String email) async {
    try {
       await SupabaseConfig.client.auth.resetPasswordForEmail(email, redirectTo: 'ursbeauty://reset-password/');
   
      return ;
    } catch (e) {
       throw Exception('Failed to send password reset email: ${e.toString()}');
    }
  }
  @override
   Future<void> resetPassword(String email, String password) async {
    try {
      await SupabaseConfig.client.auth.updateUser(UserAttributes(email: email, password: password));
      return ;
    } catch (e) {
       throw Exception('Failed to reset password: ${e.toString()}');
    }
  }

}