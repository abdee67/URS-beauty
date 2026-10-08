import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:urs_beauty/core/constants/app_colors.dart';
import 'package:urs_beauty/core/constants/app_routes.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_event.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_state.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.email});

  final String email;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {

  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  String _otp = '';
  bool _isOtpVerified = false;
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AuthBloc, bool>(
      (bloc) => bloc.state is AuthLoading,
    );
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is PasswordResetOtpVerified) {
            setState(() => _isOtpVerified = true);
          } else if (state is ResetPasswordSent) {
            _showMessage('Your password has been reset. Please sign in.');
            context.go(AppRoutes.loginScreen);
          } else if (state is AuthFailure) {
            _showMessage(state.message, isError: true);
          }
        },
        child: Stack(
          children: [
            const _PasswordResetBackground(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.sizeOf(context).height - 70,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () =>
                            context.go(AppRoutes.forgotPasswordScreen),
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: AppColors.ink,
                        tooltip: 'Back',
                      ),
                      const SizedBox(height: 20),
                      _ProgressIndicator(isPasswordStep: _isOtpVerified),
                      const SizedBox(height: 34),
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          color: _isOtpVerified
                              ? const Color(0xFFEAF0E5)
                              : const Color(0xFFFFE6D8),
                          borderRadius: BorderRadius.circular(21),
                        ),
                        child: Icon(
                          _isOtpVerified
                              ? Icons.lock_reset_rounded
                              : Icons.mark_email_read_outlined,
                          color: AppColors.clay,
                          size: 31,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        _isOtpVerified
                            ? 'Create a new\npassword'
                            : 'Check your\nemail',
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 36,
                          height: 1.08,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _isOtpVerified
                            ? 'Choose a strong password that you do not use elsewhere.'
                            : 'We sent a 6-digit verification code to ${widget.email}.',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 34),
                      _buildForm(isLoading),
                      const SizedBox(height: 28),
                      if (!_isOtpVerified)
                        Center(
                          child: TextButton(
                            onPressed: isLoading
                                ? null
                                : () => context.go(
                                    AppRoutes.forgotPasswordScreen,
                                  ),
                            child: const Text(
                              'Use a different email address',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF0D6C9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isOtpVerified) ...[
            const Text(
              'Verification code',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            OTPTextField(
              length: 6,
              width: MediaQuery.sizeOf(context).width - 96,
              textFieldAlignment: MainAxisAlignment.spaceBetween,
              fieldWidth: 42,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              onCompleted: (code) => _otp = code,
            ),
            const SizedBox(height: 12),
            const Text(
              'The code expires shortly for your security.',
              style: TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ] else ...[
            _passwordField(
              controller: _passwordCtrl,
              label: 'New password',
              obscureText: _obscurePassword,
              onVisibilityChanged: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
            const SizedBox(height: 16),
            _passwordField(
              controller: _confirmPasswordCtrl,
              label: 'Confirm new password',
              obscureText: _obscureConfirmation,
              onVisibilityChanged: () {
                setState(() => _obscureConfirmation = !_obscureConfirmation);
              },
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.clay,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.rose,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _isOtpVerified ? 'Save new password' : 'Verify code',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onVisibilityChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      autofillHints: label.startsWith('Confirm')
          ? const [AutofillHints.newPassword]
          : const [AutofillHints.newPassword],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.muted),
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.clay),
        suffixIcon: IconButton(
          onPressed: onVisibilityChanged,
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.muted,
          ),
        ),
        filled: true,
        fillColor: AppColors.field,
        border: _fieldBorder(),
        enabledBorder: _fieldBorder(),
        focusedBorder: _fieldBorder(color: AppColors.clay),
      ),
    );
  }

  OutlineInputBorder _fieldBorder({Color color = Colors.transparent}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: 1.4),
    );
  }

  void _submit() {
    if (!_isOtpVerified) {
      if (widget.email.isEmpty || _otp.length != 6) {
        _showMessage('Enter the 6-digit code from your email.', isError: true);
        return;
      }
      context.read<AuthBloc>().add(
        VerifyPasswordResetOtpRequested(widget.email, _otp),
      );
      return;
    }

    if (_passwordCtrl.text.length < 6) {
      _showMessage(
        'Use at least 6 characters for your password.',
        isError: true,
      );
      return;
    }
    if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      _showMessage('Passwords do not match. Please try again.', isError: true);
      return;
    }
    context.read<AuthBloc>().add(
      ResetPasswordRequested(widget.email, _passwordCtrl.text),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFF9B3A32) : AppColors.clay,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({required this.isPasswordStep});

  final bool isPasswordStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _step('1', 'Verify', isComplete: isPasswordStep),
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: isPasswordStep
                ? const Color(0xFF9F624F)
                : const Color(0xFFF0D6C9),
          ),
        ),
        _step('2', 'Reset', isActive: isPasswordStep),
      ],
    );
  }

  Widget _step(
    String number,
    String label, {
    bool isActive = false,
    bool isComplete = false,
  }) {
    final highlighted = isActive || isComplete;
    return Row(
      children: [
        Container(
          width: 25,
          height: 25,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: highlighted
                ? const Color(0xFF9F624F)
                : const Color(0xFFF0D6C9),
            shape: BoxShape.circle,
          ),
          child: Text(
            isComplete ? '✓' : number,
            style: TextStyle(
              color: highlighted ? Colors.white : const Color(0xFF78665F),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: TextStyle(
            color: highlighted
                ? const Color(0xFF2E2420)
                : const Color(0xFF78665F),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PasswordResetBackground extends StatelessWidget {
  const _PasswordResetBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -110,
            right: -105,
            child: Container(
              width: 275,
              height: 275,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE5D2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -130,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: const BoxDecoration(
                color: Color(0xFFF4DDD1),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
