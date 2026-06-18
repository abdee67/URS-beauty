import 'package:flutter/material.dart';
import 'package:urs_beauty/core/widgets/error_state.dart';

class RetryButton extends StatelessWidget {
  const RetryButton({
    super.key,
    required this.message,
    this.icon,
    required this.onRetry,
  });

  final String message;
  final IconData? icon;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ErrorState(message: message),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}
