import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({super.key, required this.theme, required this.title, required this.description});

  final ThemeData theme;
  final String title;
  final String description;


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE8D8), Color(0xFFFFD3B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF5C2E1F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF744534),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}