import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/config/supabase_config.dart';
import 'package:urs_beauty/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:urs_beauty/features/auth/data/models/customer_model.dart';
import 'package:urs_beauty/features/auth/domain/entities/customer_address_input.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  static const String _customerTable = 'customers';
  static const String _customerColumns =
      'id, email, first_name, last_name, phone_number, profile_image_url, '
      'created_at, updated_at, addresses:customer_addresses(*)';

  @override
  Future<Session> signIn(String email, String password) async {
    try {
      final result = await SupabaseConfig.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (result.session == null) {
        throw Exception('Failed to sign in: No session returned');
      }
      return result.session!;
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  @override
  Future<void> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
    String phone,
    CustomerAddressInput address,
  ) async {
    try {
      final result = await SupabaseConfig.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phone,
          'signup_address': address.toJson(),
        },
        emailRedirectTo: 'ursbeauty://login/',
      );
      if (result.user == null) {
        throw Exception('Failed to sign up: No user returned');
      }
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  @override
  Future<void> sendOtp(String email) async {
    try {
      final result = await SupabaseConfig.client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      if (result.messageId == null) {
        throw Exception('Failed to resend OTP: No message ID returned');
      }
    } catch (_) {
      try {
        await SupabaseConfig.client.auth.signInWithOtp(
          email: email,
          shouldCreateUser: true,
        );
      } catch (otpError) {
        throw Exception('Failed to send OTP: $otpError');
      }
    }
  }

  @override
  Future<void> verifyOTP(String email, String otp) async {
    try {
      final result = await SupabaseConfig.client.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.email,
      );
      if (result.session == null) {
        throw Exception('Failed to verify OTP: No session returned');
      }
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await SupabaseConfig.client.auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  @override
  Future<CustomerModel> getCurrentCustomer() async {
    try {
      final user = SupabaseConfig.client.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      dynamic response;
      try {
        response = await SupabaseConfig.client
            .from(_customerTable)
            .select(_customerColumns)
            .eq('id', user.id)
            .maybeSingle();
      } catch (e) {
        if (kDebugMode) {
          print('Error retrieving current customer: $e');
        }
      }

      if (response != null) {
        final customer = CustomerModel.fromJson(
          Map<String, dynamic>.from(response),
        );
        if (customer.id.isNotEmpty && customer.email.isNotEmpty) {
          return customer;
        }
      }

      final metadata = user.userMetadata ?? <String, dynamic>{};
      final fallbackCustomer = CustomerModel(
        id: user.id,
        email: user.email ?? '',
        firstName: (metadata['first_name'] ?? '').toString(),
        lastName: (metadata['last_name'] ?? '').toString(),
        phone: int.tryParse((metadata['phone_number'] ?? '0').toString()) ?? 0,
      );

      await _ensureCustomerRecord(fallbackCustomer);
      return fallbackCustomer;
    } catch (e) {
      if(kDebugMode) {
        print('Error retrieving current customer: $e');
      }
      throw Exception('Failed to retrieve customer information: $e');
    }
  }

  @override
  Future<CustomerModel> updateCustomerProfile(CustomerModel customer) async {
    try {
      await SupabaseConfig.client.auth.updateUser(
        UserAttributes(
          email: customer.email,
          data: {
            'first_name': customer.firstName,
            'last_name': customer.lastName,
            'phone_number': customer.phone.toString(),
          },
        ),
      );

      await SupabaseConfig.client.from(_customerTable).upsert({
        'id': customer.id,
        'email': customer.email,
        'first_name': customer.firstName,
        'last_name': customer.lastName,
        'phone_number': customer.phone,
        'profile_image_url': customer.profileImage,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'id');

      return customer;
    } catch (e) {
      throw Exception('Failed to update customer profile: $e');
    }
  }

  Future<void> _ensureCustomerRecord(CustomerModel customer) async {
    try {
      await SupabaseConfig.client.from(_customerTable).upsert({
        'id': customer.id,
        'email': customer.email,
        'first_name': customer.firstName,
        'last_name': customer.lastName,
        'phone_number': customer.phone,
        'profile_image_url': customer.profileImage,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'id');
    } catch (e) {
      if (kDebugMode) {
        print('Error ensuring customer record: $e');
      }
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await SupabaseConfig.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'ursbeauty://reset-password/',
      );
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  @override
  Future<void> resetPassword(String email, String password) async {
    try {
      await SupabaseConfig.client.auth.updateUser(
        UserAttributes(email: email, password: password),
      );
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }
}
