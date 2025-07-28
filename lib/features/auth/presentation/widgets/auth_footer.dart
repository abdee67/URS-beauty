import 'package:flutter/material.dart';

class AuthFooter extends StatelessWidget {
  final String prompt;
  final String buttonText;
  final VoidCallback onPressed;

  const AuthFooter({
    super.key,
    required this.prompt,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(prompt),
      TextButton(onPressed: onPressed, child: Text(buttonText)),
    ]);
  }
}
