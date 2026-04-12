import 'package:flutter/material.dart';

class StylistDetailScreen extends StatefulWidget {
  const StylistDetailScreen({super.key});

  @override
  State<StylistDetailScreen> createState() => _StylistDetailScreenState();
}

class _StylistDetailScreenState extends State<StylistDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return  Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFE5B4), // Light peach color
            Color(0xFFFFC1A6), // Soft coral color
          ],
        ),
      ),
      child: Center(
        child: Text('stylist Detail Screen'),
      ),
    );
  }
}