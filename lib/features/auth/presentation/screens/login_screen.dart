import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:urs_beauty/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_event.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_state.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State <LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State <LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      create: (_) => AuthBloc(authRepo: AuthRepositoryImpl()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
             context.go('/home');
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
                  TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
                  const SizedBox(height: 16),
                  state is AuthLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(
                                  SignInRequested(
                                    _emailController.text,
                                    _passwordController.text,
                                  ),
                                );
                          },
                          child: const Text('Login'),
                        ),
                  TextButton(
                    onPressed: () => context.go('/signup'),
                    child: const Text('Don\'t have an account? Sign up'),
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
