import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String code;
  const EmailVerificationScreen({super.key,required this.code });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool _isLoading = false;
  String? _message;
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _handleInitialSession();
    _codeController.addListener(_autoVerifyCode); 
  }
  @override
  void dispose() {
    _codeController.removeListener(_autoVerifyCode);
    super.dispose();
  }
  void _autoVerifyCode() {
    if (_codeController.text.length == 6) {
      _verifyWithCode();
    }
  }

  Future<void> _handleInitialSession() async {
    final uri = Uri.base;
    final accessToken = uri.queryParameters['access_token'];
    final refreshToken = uri.queryParameters['refresh_token'];
    final type = uri.queryParameters['type'];

    if (accessToken == null || refreshToken == null || type != 'signup') return;

    setState(() => _isLoading = true);
    
    try {
      await supabase.auth.setSession(accessToken);
      if (mounted) {
        setState(() => _message = 'Email verified successfully!');
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _message = 'Auto-verification failed. Enter code below.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyWithCode() async {
    final code = _codeController.text.trim();
    if (code.length != 6) return;

    setState(() => _isLoading = true);

    try {
      final response = await supabase.auth.verifyOTP(
        type: OtpType.signup,  // Changed from .email to .signup
        token: code,
        email: widget.code,
        
      );

      if (response.user != null && mounted) {
        setState(() => _message = 'Email verified successfully!');
        Navigator.pushReplacementNamed(context, '/login');
      }
    } on AuthException catch (e) {
      setState(() => _message = 'Error: ${e.message}');
    } catch (e) {
      setState(() => _message = 'Unknown error occurred');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendVerification() async {
    final email = supabase.auth.currentUser?.email;
    if (email == null) return;

    setState(() => _isLoading = true);
    
    try {
      await supabase.auth.resend(
        type: OtpType.signup,
        email: widget.code,
      );
      setState(() => _message = 'New code sent to $email');
    } catch (e) {
      setState(() => _message = 'Failed to resend: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Padding(

        padding: const EdgeInsets.all(20),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Text(
                    'Please enter the 6-digit code sent to ${widget.code}',
                    style: Theme.of(context).textTheme.bodyLarge
                  ),
                  const SizedBox(height: 20),
                  Text(widget.code,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
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
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: '6-digit Code',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    onChanged: (value) {
                      if (value.length == 6) _verifyWithCode();
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _verifyWithCode,
                          child: const Text('Verify'),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _resendVerification,
                    child: const Text('Resend Code'),
                  ),
                ],
              ),
      ),
    );
  }
}