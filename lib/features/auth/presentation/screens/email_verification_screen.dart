import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:urs_beauty/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_event.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_state.dart';


class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final VoidCallback? onVerified;
  const EmailVerificationScreen({super.key, required this.email, this.onVerified});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  String? _message;
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _otpController.addListener(_autoVerifyCode);
  }

  @override
  void dispose() {
    _otpController.removeListener(_autoVerifyCode);
    super.dispose();
  }

  void _autoVerifyCode() {
    if (_otpController.text.length == 6) {
      _verifyWithCode();
    }
  }
  Future<void> _verifyWithCode() async{
    if (_otpController.text.isEmpty) return;

    context.read<AuthBloc>().add(
      VerifyOtpRequested(
        widget.email,
        _otpController.text.trim(),
      ),
    );
  }
  Future<void> _resendCode() async {
    context.read<AuthBloc>().add(SendOtpRequested(widget.email));
  }

  @override
  Widget build(BuildContext context) {
   return BlocProvider(
      create: (_) => AuthBloc(authRepo: AuthRepositoryImpl()),
    child: Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body:  BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.go('/home');
            widget.onVerified?.call();
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
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
                        onPressed: (){
                          context.read<AuthBloc>().add(
                            VerifyOtpRequested(
                              widget.email,
                              _otpController.text.trim(),
                            ),
                          );
                        },
                        child:state is AuthLoading
                         ? const CircularProgressIndicator() 
                        :const Text('Verify'),
                      ),
                    ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(SendOtpRequested(widget.email));
                  },
                  child:state is AuthLoading 
                  ? const CircularProgressIndicator()
                  : const Text('Resend Code'),
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
