import 'package:flutter/material.dart';

class DistanceBadge extends StatelessWidget {
  const DistanceBadge({
    super.key,
    required this.distanceKm,
    this.foregroundColor,
    this.backgroundColor,
  });

  final double distanceKm;
  final Color? foregroundColor;
  final Color? backgroundColor;

  String get _label {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m away';
    }
    return '${distanceKm.toStringAsFixed(1)} km away';
  }

  @override
  Widget build(BuildContext context) {
    final color = foregroundColor ?? Theme.of(context).colorScheme.primary;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_on_rounded, size: 13, color: color),
        const SizedBox(width: 3),
        Text(
          _label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    if (backgroundColor == null) {
      return content;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: content,
    );
  }
}
