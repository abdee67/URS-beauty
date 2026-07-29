import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:urs_beauty/core/constants/app_button_styles.dart';
import 'package:urs_beauty/core/constants/app_colors.dart';
import 'package:urs_beauty/core/constants/app_routes.dart';
import 'package:urs_beauty/core/constants/app_sizes.dart';
import 'package:urs_beauty/features/auth/domain/entities/customer_address_input.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_event.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_state.dart';
import 'package:urs_beauty/features/auth/presentation/screens/email_verification_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController(),
      _password = TextEditingController(),
      _confirm = TextEditingController(),
      _firstName = TextEditingController(),
      _lastName = TextEditingController(),
      _phone = TextEditingController(),
      _line1 = TextEditingController(),
      _line2 = TextEditingController(),
      _city = TextEditingController(),
      _state = TextEditingController(),
      _postal = TextEditingController(),
      _country = TextEditingController();
  bool _obscurePassword = true, _obscureConfirm = true;
  double _latitude = 0, _longitude = 0;

  @override
  void dispose() {
    for (final controller in [
      _email,
      _password,
      _confirm,
      _firstName,
      _lastName,
      _phone,
      _line1,
      _line2,
      _city,
      _state,
      _postal,
      _country,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.paper,
    body: BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAddressAutofilled) _applyAddress(state.address);
        if (state is EmailVerificationSent) _showVerification();
        if (state is AuthFailure) _message(_cleanError(state.message), true);
      },
      builder: (context, state) {
        final loading = state is AuthLoading;
        final locating = state is AuthAddressLoading;
        return Stack(
          children: [
            const _SignupBackdrop(),
            SafeArea(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.screenPadding,
                    14,
                    AppSizes.screenPadding,
                    32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () => context.go(AppRoutes.loginScreen),
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: AppColors.ink,
                      ),
                      const SizedBox(height: 12),
                      const _SignupBrand(),
                      const SizedBox(height: 28),
                      const Text(
                        'Create your\nbeauty profile',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: AppSizes.headingSize,
                          height: 1.08,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'A few details and you’ll be ready to discover your next look.',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _SignupCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionTitle('About you'),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _field(
                                    _firstName,
                                    'First name',
                                    Icons.person_outline_rounded,
                                    required: true,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _field(
                                    _lastName,
                                    'Last name',
                                    Icons.person_outline_rounded,
                                    required: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _field(
                              _phone,
                              'Phone number',
                              Icons.phone_outlined,
                              type: TextInputType.phone,
                              required: true,
                            ),
                            const SizedBox(height: 16),
                            _field(
                              _email,
                              'Email address',
                              Icons.mail_outline_rounded,
                              type: TextInputType.emailAddress,
                              required: true,
                              email: true,
                            ),
                            const SizedBox(height: 24),
                            const _SectionTitle('Secure your account'),
                            const SizedBox(height: 16),
                            _field(
                              _password,
                              'Password',
                              Icons.lock_outline_rounded,
                              required: true,
                              obscure: _obscurePassword,
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
                            const SizedBox(height: 16),
                            _field(
                              _confirm,
                              'Confirm password',
                              Icons.lock_outline_rounded,
                              required: true,
                              obscure: _obscureConfirm,
                              suffix: IconButton(
                                onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                              match: true,
                            ),
                            const SizedBox(height: 26),
                            const _SectionTitle('Your address'),
                            const SizedBox(height: 8),
                            const Text(
                              'This helps us tailor services near you.',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 14),
                            OutlinedButton.icon(
                              onPressed: locating
                                  ? null
                                  : () => context.read<AuthBloc>().add(
                                      AutoFillCurrentLocationAddressRequested(),
                                    ),
                              icon: locating
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.my_location_rounded),
                              label: Text(
                                locating
                                    ? 'Finding your location...'
                                    : 'Use current location',
                              ),
                              style: AppButtonStyles.outlined,
                            ),
                            const SizedBox(height: 16),
                            _field(
                              _line1,
                              'Address line 1',
                              Icons.home_outlined,
                              required: true,
                            ),
                            const SizedBox(height: 16),
                            _field(
                              _line2,
                              'Address line 2 (optional)',
                              Icons.location_on_outlined,
                            ),
                            const SizedBox(height: 16),
                            _field(
                              _city,
                              'City',
                              Icons.location_city_outlined,
                              required: true,
                            ),
                            const SizedBox(height: 16),
                            _field(
                              _state,
                              'State / region',
                              Icons.map_outlined,
                            ),
                            const SizedBox(height: 16),
                            _field(
                              _postal,
                              'Postal code',
                              Icons.markunread_mailbox_outlined,
                            ),
                            const SizedBox(height: 16),
                            _field(
                              _country,
                              'Country',
                              Icons.public_outlined,
                              required: true,
                            ),
                            const SizedBox(height: 26),
                            SizedBox(
                              width: double.infinity,
                              height: AppSizes.buttonHeight,
                              child: ElevatedButton(
                                onPressed: loading || locating ? null : _submit,
                                style: AppButtonStyles.primary,
                                child: loading
                                    ? const _SignupLoader()
                                    : const Text(
                                        'Create account',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () => context.go(AppRoutes.loginScreen),
                          child: const Text(
                            'Already have an account?  Sign in',
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
        );
      },
    ),
  );

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool required = false,
    bool email = false,
    bool obscure = false,
    bool match = false,
    TextInputType? type,
    Widget? suffix,
  }) => TextFormField(
    controller: controller,
    keyboardType: type,
    obscureText: obscure,
    validator: (value) {
      final text = value?.trim() ?? '';
      if (required && text.isEmpty) return 'Please enter $label';
      if (email && !text.contains('@')) return 'Enter a valid email address';
      if (controller == _password && text.length < 6) {
        return 'Use at least 6 characters';
      }
      if (match && text != _password.text) return 'Passwords do not match';
      return null;
    },
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.muted),
      prefixIcon: Icon(icon, color: AppColors.clay),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.field,
      border: _inputBorder(),
      enabledBorder: _inputBorder(),
      focusedBorder: _inputBorder(AppColors.clay),
    ),
  );
  OutlineInputBorder _inputBorder([Color color = Colors.transparent]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
        borderSide: BorderSide(color: color, width: 1.4),
      );
  void _applyAddress(CustomerAddressInput a) => setState(() {
    _latitude = a.latitude;
    _longitude = a.longitude;
    _line1.text = a.addressLine1;
    _line2.text = a.addressLine2;
    _city.text = a.city;
    _state.text = a.state;
    _postal.text = a.postalCode;
    _country.text = a.country;
  });
  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      SignUpRequested(
        email: _email.text.trim(),
        password: _password.text,
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        phone: _phone.text.trim(),
        address: CustomerAddressInput(
          addressLine1: _line1.text.trim(),
          addressLine2: _line2.text.trim(),
          city: _city.text.trim(),
          state: _state.text.trim(),
          postalCode: _postal.text.trim(),
          country: _country.text.trim(),
          latitude: _latitude,
          longitude: _longitude,
        ),
      ),
    );
  }

  void _showVerification() => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => EmailVerificationScreen(
      email: _email.text.trim(),
      onVerified: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go(AppRoutes.homeScreen);
      },
    ),
  );
  String _cleanError(String message) =>
      message.replaceFirst(RegExp(r'^Exception: '), '');
  void _message(String message, bool error) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? AppColors.error : AppColors.clay,
          behavior: SnackBarBehavior.floating,
        ),
      );
}

class _SignupBackdrop extends StatelessWidget {
  const _SignupBackdrop();
  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Stack(
      children: [
        Positioned(
          top: -120,
          right: -100,
          child: _circle(AppColors.peach, 285),
        ),
        Positioned(
          bottom: -130,
          left: -85,
          child: _circle(AppColors.blush, 265),
        ),
      ],
    ),
  );
  Widget _circle(Color color, double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _SignupBrand extends StatelessWidget {
  const _SignupBrand();
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

class _SignupCard extends StatelessWidget {
  const _SignupCard({required this.child});
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: AppColors.ink,
      fontSize: 18,
      fontWeight: FontWeight.w800,
    ),
  );
}

class _SignupLoader extends StatelessWidget {
  const _SignupLoader();
  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 22,
    height: 22,
    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
  );
}
