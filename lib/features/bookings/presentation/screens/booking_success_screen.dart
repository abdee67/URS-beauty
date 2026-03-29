import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({
    super.key,
    required this.booking,
    required this.serviceName,
    required this.stylistName,
  });

  final BookingEntity booking;
  final String serviceName;
  final String stylistName;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF6),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF6EF), Color(0xFFFFDFC6)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 460),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(230),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 86,
                      height: 86,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE7F6EC),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 52,
                        color: Color(0xFF2E8B57),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Booking confirmed',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF43261D),
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your appointment for $serviceName with $stylistName is saved.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF7C5342),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SuccessRow(
                      label: 'Date',
                      value: localizations.formatMediumDate(
                        booking.scheduledAt,
                      ),
                    ),
                    _SuccessRow(
                      label: 'Time',
                      value: localizations.formatTimeOfDay(
                        TimeOfDay.fromDateTime(booking.scheduledAt),
                      ),
                    ),
                    _SuccessRow(label: 'Status', value: booking.status.name),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go('/booking'),
                        child: const Text('Book another service'),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('Back to home'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessRow extends StatelessWidget {
  const _SuccessRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF7C5342)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF43261D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
