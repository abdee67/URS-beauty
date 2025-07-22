import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:urs_beauty/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_event.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_state.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final phoneController = TextEditingController();

    return BlocProvider(
      create: (_) => AuthBloc(authRepo: AuthRepositoryImpl()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Create Account')),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is EmailVerificationSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Verification email sent! Please check your email inbox.')),
              );
              context.go('/login');
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
                  TextField(controller: firstNameController, decoration: const InputDecoration(labelText: 'First Name')),
                  TextField(controller: lastNameController, decoration: const InputDecoration(labelText: 'Last Name')),
                  TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
                  TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
                  TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),

                  const SizedBox(height: 16),
                  state is AuthLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(
                                  SignUpRequested(
                                  emailController.text.trim(),
                                  passwordController.text.trim(),
                                    phoneController.text.trim(),
                                  firstNameController.text.trim(),
                                   lastNameController.text.trim(),
                                ),
                            );
                          },
                          child: const Text('Sign Up'),
                        ),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Already have an account? Login'),
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
