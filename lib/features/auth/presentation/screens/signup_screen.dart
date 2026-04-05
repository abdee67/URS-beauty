import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
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
  bool _isGettingLocation = false;
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
                content: Text(state.message),
                backgroundColor: Colors.red[400],
              ),
            );
          }
        },
        builder: (context, state) {
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
                                  _buildTextField(
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
                                  _buildTextField(
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
                                  _buildTextField(
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
                                  _buildTextField(
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
                                  TextFormField(
                                    controller: passwordController,
                                    decoration: _inputDecoration(
                                      label: 'Password',
                                      icon: Icons.lock,
                                    ).copyWith(
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
                                  TextFormField(
                                    controller: confirmPasswordController,
                                    decoration: _inputDecoration(
                                      label: 'Confirm Password',
                                      icon: Icons.lock_outline,
                                    ).copyWith(
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
                                    ),
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
                                    onPressed: _isGettingLocation
                                        ? null
                                        : _fillAddressFromCurrentLocation,
                                    icon: _isGettingLocation
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.my_location_rounded),
                                    label: Text(
                                      _isGettingLocation
                                          ? 'Detecting location...'
                                          : 'Use current location',
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  _buildTextField(
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
                                  _buildTextField(
                                    controller: addressLine2Controller,
                                    label: 'Address Line 2',
                                    icon: Icons.location_on_outlined,
                                  ),
                                  const SizedBox(height: 15),
                                  _buildTextField(
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
                                  _buildTextField(
                                    controller: stateController,
                                    label: 'State / Region',
                                    icon: Icons.map_outlined,
                                  ),
                                  const SizedBox(height: 15),
                                  _buildTextField(
                                    controller: postalCodeController,
                                    label: 'Postal Code',
                                    icon: Icons.markunread_mailbox_outlined,
                                  ),
                                  const SizedBox(height: 15),
                                  _buildTextField(
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
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        elevation: 5,
                                      ),
                                      child: state is AuthLoading
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

  Future<void> _fillAddressFromCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      final hasPermission = await _ensureLocationPermission();
      if (!hasPermission) {
        throw Exception('Location permission is required to autofill address.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final placemark = placemarks.isNotEmpty ? placemarks.first : null;

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        addressLine1Controller.text = _composeAddressLine1(placemark);
        addressLine2Controller.text = _composeAddressLine2(placemark);
        cityController.text =
            placemark?.locality ?? placemark?.subAdministrativeArea ?? '';
        stateController.text = placemark?.administrativeArea ?? '';
        postalCodeController.text = placemark?.postalCode ?? '';
        countryController.text = placemark?.country ?? '';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  Future<bool> _ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are turned off on this device.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;
  }

  String _composeAddressLine1(Placemark? placemark) {
    final parts = <String>[
      if ((placemark?.street ?? '').trim().isNotEmpty)
        placemark!.street!.trim(),
      if ((placemark?.name ?? '').trim().isNotEmpty)
        placemark!.name!.trim(),
    ];

    return parts.isEmpty ? 'Current location' : parts.join(', ');
  }

  String _composeAddressLine2(Placemark? placemark) {
    final parts = <String>[
      if ((placemark?.subLocality ?? '').trim().isNotEmpty)
        placemark!.subLocality!.trim(),
      if ((placemark?.thoroughfare ?? '').trim().isNotEmpty)
        placemark!.thoroughfare!.trim(),
    ];

    return parts.join(', ');
  }

  void _submit(BuildContext context, AuthState state) {
    if (state is AuthLoading) {
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

  TextFormField _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label: label, icon: icon),
      validator: validator,
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.purple[300]),
      filled: true,
      fillColor: Colors.pink[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
    );
  }
}
