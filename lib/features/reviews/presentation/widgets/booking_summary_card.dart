import 'package:flutter/material.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart';

class BookingSummaryCard extends StatelessWidget {
  const BookingSummaryCard({
    super.key,
    required this.booking,
    required this.formattedDate,
  });

  final BookingEntity booking;
  final String formattedDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF6B3F32),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            booking.serviceName.isEmpty ? 'Beauty service' : booking.serviceName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            booking.stylistName.isEmpty
                ? 'Assigned stylist'
                : booking.stylistName,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFFFFE6D5),
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: Color(0xFFFFD6BA),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  formattedDate,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
