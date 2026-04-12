import 'package:flutter/material.dart';
import 'package:urs_beauty/features/bookings/presentation/widgets/summary_row_widget.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.serviceName,
    required this.stylistName,
    required this.dateLabel,
    required this.timeLabel,
    required this.priceLabel,
  });

  final String serviceName;
  final String stylistName;
  final String dateLabel;
  final String timeLabel;
  final String priceLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(225),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            serviceName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF43261D),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'with $stylistName',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: const Color(0xFF7C5342)),
          ),
          const SizedBox(height: 16),
          SummaryRow(label: 'Date', value: dateLabel),
          SummaryRow(label: 'Time', value: timeLabel),
          SummaryRow(label: 'Estimated price', value: 'From $priceLabel'),
        ],
      ),
    );
  }
}

