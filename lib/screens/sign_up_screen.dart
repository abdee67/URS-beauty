import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  String error = '';
  bool isLoading = false;

  void register() async {
    setState(() => isLoading = true);

    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (res.user != null && res.session == null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_name', nameController.text.trim());
        await prefs.setString('pending_phone', phoneController.text.trim());

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Verify Email'),
            content: Text(
              'We sent a verification email to ${emailController.text.trim()}.\n\n'
              'Please verify it, then return and log in.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        setState(() => error = 'Unexpected signup result.');
      }
    } on AuthException catch (e) {
      if (e.message.contains('already registered')) {
        setState(() => error = 'Email is already in use. Try logging in.');
      } else {
        setState(() => error = e.message);
      }
    } catch (e) {
      setState(() => error = e.toString());
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 16),
            if (error.isNotEmpty)
              Text(error, style: TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: isLoading ? null : register,
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Sign Up'),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                      // Navigate to login screen
                      Navigator.of(context).pop();
                    },
              child: Text("Already have an account? Log in"),
            ),
          ],
        ),
      ),
    );
  }
}
