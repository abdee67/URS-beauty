import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:urs_beauty/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_event.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_state.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final VoidCallback? onVerified;
  const EmailVerificationScreen({
    super.key,
    required this.email,
    this.onVerified,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  String? _message;
  final _otpController = TextEditingController();
  int _countdown = 0;
  Timer? _timer;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdown = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
      }
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
            if (state is OtpVerified) {
              context.go('/home');
              widget.onVerified?.call();
            } else if (state is OtpSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('New code sent to your email!'),
                  backgroundColor: Colors.purple[600],
                ),
              );
              _startCountdown();
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
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.pink[100]!, Colors.purple[100]!],
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 40,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/logo.png', // Add your own asset
                          height: 120,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Verify Your Email',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[800],
                            fontFamily: 'PlayfairDisplay',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'We sent a 6-digit code to:',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.email,
                          style: TextStyle(
                            color: Colors.purple[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _otpController,
                                decoration: InputDecoration(
                                  labelText: 'Verification Code',
                                  prefixIcon: Icon(
                                    Icons.verified_user,
                                    color: Colors.purple[300],
                                  ),
                                  filled: true,
                                  fillColor: Colors.pink[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  counterText: '',
                                ),
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the verification code';
                                  }
                                  if (value.length != 6) {
                                    return 'Code must be 6 digits';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              if (_message != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    _message!,
                                    style: TextStyle(
                                      color: _message!.contains('failed')
                                          ? Colors.red[400]
                                          : Colors.green[400],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<AuthBloc>().add(
                                        VerifyOtpRequested(
                                          widget.email,
                                          _otpController.text.trim(),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple[600],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: state is AuthLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          'VERIFY',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextButton(
                                onPressed: _countdown == 0
                                    ? () {
                                        context.read<AuthBloc>().add(
                                          SendOtpRequested(widget.email),
                                        );
                                      }
                                    : null,
                                child: Text(
                                  _countdown == 0
                                      ? 'Resend Code'
                                      : 'Resend in $_countdown seconds',
                                  style: TextStyle(
                                    color: _countdown == 0
                                        ? Colors.purple[600]
                                        : Colors.grey[400],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () => context.go('/login'),
                                child: Text(
                                  'Back to Login',
                                  style: TextStyle(color: Colors.purple[600]),
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
            );
          },
        ),
      ),
    );
  }
}
