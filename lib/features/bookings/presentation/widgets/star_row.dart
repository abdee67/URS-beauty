import 'package:flutter/material.dart';

class StarRow extends StatelessWidget {
  const StarRow({super.key, required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final filledStars = rating.round().clamp(0, 5);

    return Row(
      children: List.generate(
        5,
        (index) => Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Icon(
            index < filledStars
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color: const Color(0xFFF2A33A),
            size: 20,
          ),
        ),
      ),
    );
  }
}