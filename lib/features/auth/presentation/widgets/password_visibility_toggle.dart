import 'package:flutter/material.dart';

class PasswordVisibilityToggle extends StatelessWidget {
  final bool visible;
  final VoidCallback onToggle;

  const PasswordVisibilityToggle({
    super.key,
    required this.visible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(visible ? Icons.visibility_off : Icons.visibility),
      onPressed: onToggle,
    );
  }
}
