import 'package:flutter/material.dart';
import 'package:urs_beauty/core/constants/app_colors.dart';
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.clay.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.field,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.clay,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Summary',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                            letterSpacing: 0.2,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Service breakdown & details',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.muted,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: AppColors.border, height: 1),
          ),
          SummaryRow(label: 'Service', value: serviceName),
          SummaryRow(label: 'Stylist', value: stylistName),
          SummaryRow(label: 'Date', value: dateLabel),
          SummaryRow(label: 'Time', value: timeLabel),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.field,
                  AppColors.peach.withValues(alpha: 0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.rose.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.payments_outlined,
                      size: 18,
                      color: AppColors.clay,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Estimated Price',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                    ),
                  ],
                ),
                Text(
                  'From \$$priceLabel',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.clay,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


