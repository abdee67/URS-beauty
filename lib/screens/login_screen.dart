import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'otpverification.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPhoneLogin = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  String error = '';
  bool isLoading = false;

  void loginWithEmail() async {
    setState(() => isLoading = true);
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response.session != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() => error = "Please verify your email before logging in.");
      }
    } catch (e) {
      setState(() => error = e.toString());
    }
    setState(() => isLoading = false);
  }

  void loginWithPhone() async {
    setState(() => isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithOtp(
        phone: phoneController.text.trim(),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              OtpVerificationScreen(phone: phoneController.text.trim()),
        ),
      );
    } catch (e) {
      setState(() => error = e.toString());
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ToggleButtons(
              isSelected: [!isPhoneLogin, isPhoneLogin],
              onPressed: (i) => setState(() {
                isPhoneLogin = i == 1;
                error = '';
              }),
              children: [Text('Email Login'), Text('Phone Login')],
            ),
            SizedBox(height: 20),

            if (!isPhoneLogin) ...[
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: isLoading ? null : loginWithEmail,
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Login'),
              ),
            ],

            if (isPhoneLogin) ...[
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number (+251...)',
                ),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: isLoading ? null : loginWithPhone,
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Send OTP'),
              ),
            ],

            if (error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(error, style: TextStyle(color: Colors.red)),
              ),

            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
