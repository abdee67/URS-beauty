import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:urs_beauty/core/widgets/custom_textField.dart';
import 'package:urs_beauty/features/auth/domain/entities/customer_address_input.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_event.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_state.dart';
import 'package:urs_beauty/features/auth/presentation/screens/email_verification_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final postalCodeController = TextEditingController();
  final countryController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _passwordsMatch = true;
  double _latitude = 0;
  double _longitude = 0;

  void _validatePasswords() {
    setState(() {
      _passwordsMatch =
          passwordController.text == confirmPasswordController.text;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    postalCodeController.dispose();
    countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAddressAutofilled) {
            _applyAutofilledAddress(state.address);
            return;
          }

          if (state is EmailVerificationSent) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => EmailVerificationScreen(
                email: emailController.text.trim(),
                onVerified: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Account created successfully!'),
                      backgroundColor: Colors.purple[600],
                    ),
                  );
                  context.go('/home');
                },
              ),
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_cleanErrorMessage(state.message)),
                backgroundColor: Colors.red[400],
              ),
            );
          }
        },
        builder: (context, state) {
          final isSigningUp = state is AuthLoading;
          final isGettingLocation = state is AuthAddressLoading;

          return Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.pink[100]!, Colors.purple[100]!],
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 30),
                  child: Column(
                    children: [
                      Image.asset('assets/images/logo.png', height: 80),
                      const SizedBox(height: 10),
                      Text(
                        'Join URS Beauty',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[800],
                          fontFamily: 'PlayfairDisplay',
                        ),
                      ),
                      const Text(
                        'Create your beauty profile',
                        style: TextStyle(
                          color: Colors.purple,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  CustomTextField(
                                    controller: firstNameController,
                                    label: 'First Name',
                                    icon: Icons.person,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your first name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  CustomTextField(
                                    controller: lastNameController,
                                    label: 'Last Name',
                                    icon: Icons.person_outline,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your last name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  CustomTextField(
                                    controller: phoneController,
                                    label: 'Phone Number',
                                    icon: Icons.phone,
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your phone number';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  CustomTextField(
                                    controller: emailController,
                                    label: 'Email',
                                    icon: Icons.email,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  CustomTextField(
                                    controller: passwordController,
                                    label: 'Password',
                                    icon: Icons.lock,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.purple[300],
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),

                                    obscureText: _obscurePassword,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a password';
                                      }
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                    onChanged: (_) => _validatePasswords(),
                                  ),
                                  const SizedBox(height: 15),
                                  CustomTextField(
                                    controller: confirmPasswordController,
                                    label: 'Confirm Password',
                                    icon: Icons.lock_outline,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.purple[300],
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword;
                                        });
                                      },
                                    ),
                                    errorText: _passwordsMatch
                                        ? null
                                        : 'Passwords do not match',

                                    obscureText: _obscureConfirmPassword,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please confirm your password';
                                      }
                                      if (value != passwordController.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                    onChanged: (_) => _validatePasswords(),
                                  ),
                                  const SizedBox(height: 24),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Address',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple[700],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  OutlinedButton.icon(
                                    onPressed: isGettingLocation
                                        ? null
                                        : () {
                                            context.read<AuthBloc>().add(
                                              AutoFillCurrentLocationAddressRequested(),
                                            );
                                          },
                                    icon: isGettingLocation
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.my_location_rounded),
                                    label: Text(
                                      isGettingLocation
                                          ? 'Detecting location...'
                                          : 'Use current location',
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  CustomTextField(
                                    controller: addressLine1Controller,
                                    label: 'Address Line 1',
                                    icon: Icons.home_outlined,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter address line 1';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  CustomTextField(
                                    controller: addressLine2Controller,
                                    label: 'Address Line 2',
                                    icon: Icons.location_on_outlined,
                                  ),
                                  const SizedBox(height: 15),
                                  CustomTextField(
                                    controller: cityController,
                                    label: 'City',
                                    icon: Icons.location_city,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your city';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  CustomTextField(
                                    controller: stateController,
                                    label: 'State / Region',
                                    icon: Icons.map_outlined,
                                  ),
                                  const SizedBox(height: 15),
                                  CustomTextField(
                                    controller: postalCodeController,
                                    label: 'Postal Code',
                                    icon: Icons.markunread_mailbox_outlined,
                                  ),
                                  const SizedBox(height: 15),
                                  CustomTextField(
                                    controller: countryController,
                                    label: 'Country',
                                    icon: Icons.public,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your country';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 25),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: () => _submit(context, state),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple[600],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
                                        ),
                                        elevation: 5,
                                      ),
                                      child: isSigningUp
                                          ? const CircularProgressIndicator(
                                              color: Colors.white,
                                            )
                                          : const Text(
                                              'CREATE ACCOUNT',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account?',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                TextButton(
                                  onPressed: () => context.go('/login'),
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.purple[600],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _applyAutofilledAddress(CustomerAddressInput address) {
    setState(() {
      _latitude = address.latitude;
      _longitude = address.longitude;
      addressLine1Controller.text = address.addressLine1;
      addressLine2Controller.text = address.addressLine2;
      cityController.text = address.city;
      stateController.text = address.state;
      postalCodeController.text = address.postalCode;
      countryController.text = address.country;
    });
  }

  String _cleanErrorMessage(String message) {
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    return message;
  }

  void _submit(BuildContext context, AuthState state) {
    if (state is AuthLoading || state is AuthAddressLoading) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthBloc>().add(
      SignUpRequested(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        phone: phoneController.text.trim(),
        address: CustomerAddressInput(
          addressLine1: addressLine1Controller.text.trim(),
          addressLine2: addressLine2Controller.text.trim(),
          city: cityController.text.trim(),
          state: stateController.text.trim(),
          postalCode: postalCodeController.text.trim(),
          country: countryController.text.trim(),
          latitude: _latitude,
          longitude: _longitude,
        ),
      ),
    );
  }
}
