import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  OtpVerificationScreen({required this.phone});

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final otpController = TextEditingController();
  bool isLoading = false;
  String error = '';

  void verifyOtp() async {
    setState(() => isLoading = true);
    try {
      final res = await Supabase.instance.client.auth.verifyOTP(
        phone: widget.phone,
        token: otpController.text.trim(),
        type: OtpType.sms,
      );

      if (res.session != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() => error = 'Invalid OTP or session expired.');
      }
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('Enter the OTP sent to ${widget.phone}'),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'OTP Code'),
            ),
            if (error.isNotEmpty)
              Text(error, style: TextStyle(color: Colors.red)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : verifyOtp,
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Verify & Login'),
            ),
          ],
        ),
      ),
    );
  }
}
