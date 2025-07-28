import 'package:flutter/material.dart';

class ClientAuthForm extends StatelessWidget {
  final List<Widget> children;
  final VoidCallback onSubmit;
  final bool loading;

  const ClientAuthForm({
    super.key,
    required this.children,
    required this.onSubmit,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ...children,
      const SizedBox(height: 20),
      loading
          ? const CircularProgressIndicator()
          : ElevatedButton(
              onPressed: onSubmit,
              child: const Text('Continue'),
            ),
    ]);
  }
}
