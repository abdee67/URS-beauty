import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_event.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_state.dart';
import 'package:urs_beauty/features/auth/data/repositories/auth_repository_impl.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});
  final _emailCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(authRepo: AuthRepositoryImpl()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Forgot Password')),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is ForgotPasswordSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Password reset email sent')),
              );
              context.go('/reset-password?email=${_emailCtrl.text.trim()}');
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
                  const Text('Forgot Password'),
                  TextField(
                    controller: _emailCtrl,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                        ForgotPasswordRequested(_emailCtrl.text.trim()),
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
