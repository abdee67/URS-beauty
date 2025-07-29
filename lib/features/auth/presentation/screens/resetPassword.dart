import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_event.dart';
import 'package:urs_beauty/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_state.dart';

class ResetPasswordScreen extends StatefulWidget {
  ResetPasswordScreen({super.key});
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(authRepo: AuthRepositoryImpl()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Reset Password')),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is ResetPasswordSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Password reset successfully')),
              );
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
                  const Text('Reset Password'),
                  OTPTextField(
                    length: 6,
                    width: MediaQuery.of(context).size.width,
                    textFieldAlignment: MainAxisAlignment.spaceBetween,
                    fieldWidth: 50,
                    style: const TextStyle(fontSize: 20),
                    onCompleted: (pin) {
                      print("Completed: $pin");
                    },
                  ),
                  TextField(
                    controller: widget._passwordCtrl,
                    obscureText: true,
                    obscuringCharacter: '*',
                    decoration: InputDecoration(labelText: 'Password'),
                  ),
                  TextField(
                    controller: widget._confirmPasswordCtrl,
                    obscureText: true,
                    obscuringCharacter: '*',
                    decoration: InputDecoration(labelText: 'Confirm Password'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                        ResetPasswordRequested(
                          widget._emailCtrl.text.trim(),
                          widget._passwordCtrl.text.trim(),
                        ),
                      );
                    },
                    child: const Text('Reset Password'),
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
