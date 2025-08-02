import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:urs_beauty/features/auth/data/repositories/auth_repository_impl.dart';
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

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _passwordsMatch = true;

  void _validatePasswords() {
    setState(() {
      _passwordsMatch =
          passwordController.text == confirmPasswordController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(authRepo: AuthRepositoryImpl()),
      child: Scaffold(
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
                  // Header section
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
                  // Form section
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
                            color: Colors.purple.withOpacity(0.1),
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
                                    TextFormField(
                                      controller: firstNameController,
                                      decoration: InputDecoration(
                                        labelText: 'First Name',
                                        prefixIcon: Icon(
                                          Icons.person,
                                          color: Colors.purple[300],
                                        ),
                                        filled: true,
                                        fillColor: Colors.pink[50],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your first name';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 15),
                                    TextFormField(
                                      controller: lastNameController,
                                      decoration: InputDecoration(
                                        labelText: 'Last Name',
                                        prefixIcon: Icon(
                                          Icons.person_outline,
                                          color: Colors.purple[300],
                                        ),
                                        filled: true,
                                        fillColor: Colors.pink[50],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your last name';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 15),
                                    TextFormField(
                                      controller: phoneController,
                                      decoration: InputDecoration(
                                        labelText: 'Phone Number',
                                        prefixIcon: Icon(
                                          Icons.phone,
                                          color: Colors.purple[300],
                                        ),
                                        filled: true,
                                        fillColor: Colors.pink[50],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      keyboardType: TextInputType.phone,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your phone number';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 15),
                                    TextFormField(
                                      controller: emailController,
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        prefixIcon: Icon(
                                          Icons.email,
                                          color: Colors.purple[300],
                                        ),
                                        filled: true,
                                        fillColor: Colors.pink[50],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
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
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        prefixIcon: Icon(
                                          Icons.lock,
                                          color: Colors.purple[300],
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: Colors.purple[300],
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                        filled: true,
                                        fillColor: Colors.pink[50],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          borderSide: BorderSide.none,
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
                                      decoration: InputDecoration(
                                        labelText: 'Confirm Password',
                                        prefixIcon: Icon(
                                          Icons.lock_outline,
                                          color: Colors.purple[300],
                                        ),
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
                                        filled: true,
                                        fillColor: Colors.pink[50],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          borderSide: BorderSide.none,
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
                                    const SizedBox(height: 25),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            context.read<AuthBloc>().add(
                                              SignUpRequested(
                                                emailController.text.trim(),
                                                passwordController.text.trim(),
                                                phoneController.text.trim(),
                                                firstNameController.text.trim(),
                                                lastNameController.text.trim(),
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.purple[600],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
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
                                    "Already have an account?",
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
      ),
    );
  }
}
