import 'package:flutter/material.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart';
import 'package:urs_beauty/features/payments/domain/entity/payment_entity.dart'
    as payment_domain;

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({
    super.key,
    required this.booking,
    required this.payment,
    required this.serviceName,
    required this.stylistName,
  });

  final BookingEntity booking;
  final payment_domain.PaymentEntity payment;
  final String serviceName;
  final String stylistName;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final paidLabel =
        '${payment.currency} ${payment.amount.toStringAsFixed(2)}';
    final reference =
        payment.transactionReference ??
        payment.stripePaymentIntentId ??
        payment.id;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF704434), Color(0xFFB16B50), Color(0xFFF4C28A)],
          ),
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 480),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x29000000),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2FBF3),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFCCEDD2),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          size: 62,
                          color: Color(0xFF2E9B47),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Payment Confirmed',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF43261D),
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Your booking is now secured and marked for service fulfillment.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF6D574D),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 26),
                      Divider(color: Colors.grey.shade200),
                      const SizedBox(height: 18),
                      _SuccessRow(label: 'Service', value: serviceName),
                      _SuccessRow(label: 'Stylist', value: stylistName),
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
                      _SuccessRow(
                        label: 'Paid',
                        value: paidLabel,
                        highlight: true,
                      ),
                      _SuccessRow(label: 'Reference', value: reference),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B3F32),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Return to home',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
  const _SuccessRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF7B6156),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: highlight
                    ? const Color(0xFF6B3F32)
                    : const Color(0xFF43261D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
