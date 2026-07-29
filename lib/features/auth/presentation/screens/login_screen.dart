import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:urs_beauty/core/constants/app_button_styles.dart';
import 'package:urs_beauty/core/constants/app_colors.dart';
import 'package:urs_beauty/core/constants/app_routes.dart';
import 'package:urs_beauty/core/constants/app_sizes.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_event.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_state.dart';
import 'package:urs_beauty/features/auth/presentation/widgets/session_checking_splash.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isCheckingSession = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration.zero, () {
      if (mounted) context.read<AuthBloc>().add(CheckStartupSessionRequested());
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.go(AppRoutes.homeScreen);
          } else if (state is AuthLoggedOut) {
            setState(() => _isCheckingSession = false);
          } else if (state is AuthFailure) {
            setState(() => _isCheckingSession = false);
            _message(state.message, true);
          }
        },
        builder: (context, state) {
          if (_isCheckingSession) return const SessionCheckingSplash();
          return _AuthBackdrop(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _LogoLockup(),
                    const SizedBox(height: 58),
                    const Text('Welcome\nback', style: _headingStyle),
                    const SizedBox(height: 12),
                    const Text(
                      'Sign in to continue your beauty journey.',
                      style: TextStyle(color: AppColors.muted, fontSize: 16),
                    ),
                    const SizedBox(height: 36),
                    _AuthCard(
                      child: Column(
                        children: [
                          _input(
                            controller: _emailController,
                            label: 'Email address',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: AppSizes.fieldGap),
                          _input(
                            controller: _passwordController,
                            label: 'Password',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            suffix: IconButton(
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () =>
                                  context.go(AppRoutes.forgotPasswordScreen),
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color: AppColors.clay,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: AppSizes.buttonHeight,
                            child: ElevatedButton(
                              onPressed: state is AuthLoading ? null : _login,
                              style: AppButtonStyles.primary,
                              child: state is AuthLoading
                                  ? const _Loader()
                                  : const Text('Sign in', style: _buttonText),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () => context.go(AppRoutes.signupScreen),
                        child: const Text(
                          'New to URS Beauty?  Create an account',
                          style: TextStyle(
                            color: AppColors.clay,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _login() {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _message('Enter your email and password.', true);
      return;
    }
    context.read<AuthBloc>().add(
      SignInRequested(_emailController.text.trim(), _passwordController.text),
    );
  }

  void _message(String message, bool error) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? AppColors.error : AppColors.clay,
          behavior: SnackBarBehavior.floating,
        ),
      );
}

const _headingStyle = TextStyle(
  color: AppColors.ink,
  fontSize: AppSizes.headingSize,
  height: 1.08,
  fontWeight: FontWeight.w800,
);
const _buttonText = TextStyle(fontWeight: FontWeight.w700, fontSize: 16);

class _AuthBackdrop extends StatelessWidget {
  const _AuthBackdrop({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned(top: -110, right: -100, child: _circle(AppColors.peach, 285)),
      Positioned(bottom: -135, left: -90, child: _circle(AppColors.blush, 265)),
      child,
    ],
  );
  Widget _circle(Color color, double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _LogoLockup extends StatelessWidget {
  const _LogoLockup();
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 48,
        height: 48,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(color: Color(0x16000000), blurRadius: 14),
          ],
        ),
        child: Image.asset('assets/images/logo.png'),
      ),
      const SizedBox(width: 12),
      const Text(
        'URS Beauty',
        style: TextStyle(
          color: AppColors.ink,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSizes.cardPadding),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .93),
      borderRadius: BorderRadius.circular(AppSizes.pageRadius),
      border: Border.all(color: AppColors.border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 28,
          offset: Offset(0, 12),
        ),
      ],
    ),
    child: child,
  );
}

Widget _input({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  TextInputType? keyboardType,
  bool obscureText = false,
  Widget? suffix,
}) => TextField(
  controller: controller,
  keyboardType: keyboardType,
  obscureText: obscureText,
  decoration: InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: AppColors.muted),
    prefixIcon: Icon(icon, color: AppColors.clay),
    suffixIcon: suffix,
    filled: true,
    fillColor: AppColors.field,
    border: _border(),
    enabledBorder: _border(),
    focusedBorder: _border(AppColors.clay),
  ),
);
OutlineInputBorder _border([Color color = Colors.transparent]) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
      borderSide: BorderSide(color: color, width: 1.4),
    );

class _Loader extends StatelessWidget {
  const _Loader();
  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 22,
    height: 22,
    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
  );
}
