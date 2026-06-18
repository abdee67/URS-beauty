import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/config/supabase_config.dart';
import 'package:urs_beauty/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:urs_beauty/features/auth/data/models/customer_model.dart';
import 'package:urs_beauty/features/auth/data/models/customer_address_model.dart';
import 'package:urs_beauty/features/auth/domain/entities/customer_address_input.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  static const String _customerTable = 'customers';
  static const String _customerAddressTable = 'customer_addresses';
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

      final user = result.user ?? SupabaseConfig.client.auth.currentUser;
      if (user == null) {
        await _signOutQuietly();
        throw Exception('Failed to sign in: No user returned');
      }

      final isCustomerAccount = await _isCurrentCustomerAccount();
      if (!isCustomerAccount) {
        await _signOutQuietly();
        throw Exception(
          'This account is not a customer account. Please use the UR Stylist '
          'app or sign up as a customer.',
        );
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
          'app_role': 'customer',
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

      await _ensureCustomerProfileFromUser(
        result.user!,
        fallbackEmail: email,
        rethrowErrors: false,
      );
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
          data: const {'app_role': 'customer'},
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

      final verifiedUser =
          result.user ?? SupabaseConfig.client.auth.currentUser;
      if (verifiedUser == null) {
        throw Exception('Failed to verify OTP: No user returned');
      }

      await _claimCustomerRoleForCurrentUser();

      await _ensureCustomerProfileFromUser(
        verifiedUser,
        fallbackEmail: email,
        rethrowErrors: true,
      );
      await _requireCurrentCustomerAccountForLogin();
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
      await _requireCurrentCustomerAccount();

      final response = await _fetchCustomerResponse(user.id);

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
      await _ensureCustomerProfileFromUser(
        user,
        fallbackEmail: user.email ?? '',
        rethrowErrors: false,
      );

      final refreshedResponse = await _fetchCustomerResponse(user.id);
      if (refreshedResponse != null) {
        return CustomerModel.fromJson(
          Map<String, dynamic>.from(refreshedResponse),
        );
      }

      return fallbackCustomer;
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving current customer: $e');
      }
      throw Exception('Failed to retrieve customer information: $e');
    }
  }

  @override
  Future<CustomerModel> updateCustomerProfile(CustomerModel customer) async {
    try {
      await _requireCurrentCustomerAccount();

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

  Future<void> _ensureCustomerProfileFromUser(
    User user, {
    required String fallbackEmail,
    required bool rethrowErrors,
  }) async {
    try {
      final customer = _customerFromUser(user, fallbackEmail: fallbackEmail);
      await _ensureCustomerRecord(customer);
      await _ensureSignupAddress(
        customerId: customer.id,
        metadata: user.userMetadata ?? const <String, dynamic>{},
      );
    } catch (e) {
      final isBookingsPolicyRecursionError = _isBookingsPolicyRecursionError(e);
      if (kDebugMode) {
        print(
          isBookingsPolicyRecursionError
              ? 'Ignoring signup customer profile bootstrap error caused by bookings policy recursion: $e'
              : 'Error ensuring signup customer profile: $e',
        );
      }
      if (rethrowErrors && !isBookingsPolicyRecursionError) {
        rethrow;
      }
    }
  }

  bool _isBookingsPolicyRecursionError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains(
          'infinite recursion detected in policy for relation "bookings"',
        ) ||
        message.contains('"code":"42p17"') ||
        message.contains('code: 42p17');
  }

  CustomerModel _customerFromUser(User user, {required String fallbackEmail}) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};

    return CustomerModel(
      id: user.id,
      email: (user.email ?? fallbackEmail).trim(),
      firstName: (metadata['first_name'] ?? '').toString(),
      lastName: (metadata['last_name'] ?? '').toString(),
      phone: int.tryParse((metadata['phone_number'] ?? '0').toString()) ?? 0,
    );
  }

  Future<bool> _isCurrentCustomerAccount() async {
    try {
      final response = await SupabaseConfig.client.rpc('is_current_customer');
      return response == true;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking customer role: $e');
      }
      return false;
    }
  }

  Future<void> _requireCurrentCustomerAccount() async {
    final isCustomerAccount = await _isCurrentCustomerAccount();
    if (!isCustomerAccount) {
      throw Exception('Current user is not a customer account.');
    }
  }

  Future<void> _requireCurrentCustomerAccountForLogin() async {
    final isCustomerAccount = await _isCurrentCustomerAccount();
    if (!isCustomerAccount) {
      await _signOutQuietly();
      throw Exception(
        'This account is not a customer account. Please use the UR Stylist app '
        'or sign up as a customer.',
      );
    }
  }

  Future<void> _claimCustomerRoleForCurrentUser() async {
    try {
      await SupabaseConfig.client.rpc('claim_customer_role');
    } catch (e) {
      await _signOutQuietly();
      throw Exception(
        'This account cannot be used as a customer account. Please use the UR '
        'Stylist app if this is a stylist account.',
      );
    }
  }

  Future<void> _signOutQuietly() async {
    try {
      await SupabaseConfig.client.auth.signOut();
    } catch (_) {}
  }

  Future<void> _ensureSignupAddress({
    required String customerId,
    required Map<String, dynamic> metadata,
  }) async {
    final signupAddress = metadata['signup_address'];
    if (signupAddress is! Map) {
      return;
    }

    final existingAddress = await SupabaseConfig.client
        .from(_customerAddressTable)
        .select('id')
        .eq('customer_id', customerId)
        .limit(1)
        .maybeSingle();

    if (existingAddress != null) {
      return;
    }

    final payload = Map<String, dynamic>.from(signupAddress);
    payload['customer_id'] = customerId;
    payload['is_default'] = true;

    await createCustomerAddress(payload);
  }

  Future<dynamic> _fetchCustomerResponse(String userId) async {
    try {
      return await SupabaseConfig.client
          .from(_customerTable)
          .select(_customerColumns)
          .eq('id', userId)
          .maybeSingle();
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving current customer: $e');
      }
      return null;
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

  @override
  Future<CustomerAddressModel> createCustomerAddress(
    Map<String, dynamic> payload,
  ) async {
    try {
      await _requireCurrentCustomerAccount();

      final currentUser = SupabaseConfig.client.auth.currentUser;
      final payloadWithCustomer = Map<String, dynamic>.from(payload);
      final resolvedCustomerId =
          (payloadWithCustomer['customer_id'] ?? currentUser?.id ?? '')
              .toString()
              .trim();

      if (resolvedCustomerId.isEmpty) {
        throw Exception('No authenticated customer found for address creation');
      }

      payloadWithCustomer['customer_id'] = resolvedCustomerId;

      if (payloadWithCustomer['is_default'] == null) {
        final existingAddress = await SupabaseConfig.client
            .from(_customerAddressTable)
            .select('id')
            .eq('customer_id', resolvedCustomerId)
            .limit(1)
            .maybeSingle();
        payloadWithCustomer['is_default'] = existingAddress == null;
      }

      final response = await SupabaseConfig.client
          .from(_customerAddressTable)
          .insert(payloadWithCustomer)
          .select()
          .single();

      return CustomerAddressModel.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      throw Exception('Failed to create customer address: $e');
    }
  }
}
