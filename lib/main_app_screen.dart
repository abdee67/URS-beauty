import 'package:flutter/material.dart';

import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/auth/presentation/screens/sign_in_screen.dart';
import 'features/service-listing/presentation/service_list_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainAppScreen extends StatelessWidget {
  const MainAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            return const ServiceListScreen();
          } else {
            return const SignInScreen();
          }
        },
      ),
    );
  }
}