import 'package:flutter/material.dart';

/// A general-purpose card container with a title, subtitle, and arbitrary
/// child content. Used for every section on the payment screen.
class PaymentSectionCard extends StatelessWidget {
  const PaymentSectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0D7CB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF43261D),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF7B6156),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

/// A label/value row inside a booking summary card.
/// Set [highlight] to true to render the value in the brand accent colour
/// (used for the amount row).
class PaymentSummaryRow extends StatelessWidget {
  const PaymentSummaryRow({
    super.key,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF7B6156),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: highlight
                    ? const Color(0xFF6B3F32)
                    : const Color(0xFF43261D),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single item in the safety-checks list with a verified icon.
class PaymentChecklistItem extends StatelessWidget {
  const PaymentChecklistItem(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(
            Icons.verified_rounded,
            size: 18,
            color: Color(0xFF8B5C49),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF5F463C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Booking summary card that wraps [PaymentSectionCard] and renders a
/// structured list of service/stylist/date/time/amount rows.
class PaymentSummaryCard extends StatelessWidget {
  const PaymentSummaryCard({
    super.key,
    required this.title,
    required this.stylistName,
    required this.dateLabel,
    required this.timeLabel,
    required this.amountLabel,
  });

  final String title;
  final String stylistName;
  final String dateLabel;
  final String timeLabel;
  final String amountLabel;

  @override
  Widget build(BuildContext context) {
    return PaymentSectionCard(
      title: 'Booking summary',
      subtitle:
          'Payment is collected after service completion and only becomes '
          'final once payment verification succeeds.',
      child: Column(
        children: [
          PaymentSummaryRow(label: 'Service', value: title),
          PaymentSummaryRow(label: 'Stylist', value: stylistName),
          PaymentSummaryRow(label: 'Date', value: dateLabel),
          PaymentSummaryRow(label: 'Time', value: timeLabel),
          PaymentSummaryRow(
            label: 'Amount',
            value: amountLabel,
            highlight: true,
          ),
        ],
      ),
    );
  }
}
