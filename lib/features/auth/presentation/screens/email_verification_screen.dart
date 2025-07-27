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

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
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
        appBar: AppBar(title: const Text('Verify Email')),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is OtpVerified) {
              context.go('/home');
              widget.onVerified?.call();
            } else if (state is OtpSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('New code sent to your email!')),
              );
              _startCountdown(); // Restart countdown when OTP is sent
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Please enter the 6-digit code sent to your email.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  if (_message != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        _message!,
                        style: TextStyle(
                          color: _message!.contains('failed')
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ),
                  TextField(
                    controller: _otpController,
                    decoration: const InputDecoration(
                      labelText: '6-digit Code',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(
                          VerifyOtpRequested(
                            widget.email,
                            _otpController.text.trim(),
                          ),
                        );
                      },
                      child: const Text('Verify'),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                          : 'Resend Code in ${_countdown}s',
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
