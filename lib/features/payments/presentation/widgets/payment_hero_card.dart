import 'package:flutter/material.dart';

/// Full-bleed gradient card displayed at the top of the payment screen.
/// Shows the service name, stylist name, and total amount due.
class PaymentHeroCard extends StatelessWidget {
  const PaymentHeroCard({
    super.key,
    required this.serviceName,
    required this.stylistName,
    required this.amountLabel,
  });

  final String serviceName;
  final String stylistName;
  final String amountLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7A4A39), Color(0xFFA7684F)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Complete your service payment',
            style: TextStyle(
              color: Color(0xFFFFE9DC),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            serviceName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (stylistName.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'with $stylistName',
              style: const TextStyle(color: Color(0xFFFFE9DC), fontSize: 15),
            ),
          ],
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: Text(
              amountLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
