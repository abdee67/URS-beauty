import 'package:flutter/material.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart';

class BookingStatusBadge extends StatelessWidget {
  const BookingStatusBadge({super.key, required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, background, foreground) = switch (status) {
      BookingStatus.confirmed => (
        'Confirmed',
        const Color(0xFFE6F5EB),
        const Color(0xFF287A4B),
      ),
      BookingStatus.completed => (
        'Completed',
        const Color(0xFFE6F5EB),
        const Color.fromARGB(255, 227, 131, 21),
      ),
      BookingStatus.passed => (
        'Passed',
        const Color(0xFFE6F5EB),
        const Color.fromARGB(255, 227, 210, 21),
      ),
      BookingStatus.cancelled => (
        'Cancelled',
        const Color(0xFFFBE9E7),
        const Color(0xFFB54432),
      ),
      _ => ('Scheduled', const Color(0xFFF5E8D9), const Color(0xFF7A4A39)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}






