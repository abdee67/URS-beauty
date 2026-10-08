import 'package:flutter/material.dart';
import 'package:urs_beauty/core/constants/app_colors.dart';
import 'package:urs_beauty/features/auth/domain/entities/customer_address_entity.dart';
import 'package:urs_beauty/features/bookings/presentation/widgets/address_option_card_widget.dart';

class SelectedAddressPreview extends StatelessWidget {
  const SelectedAddressPreview({super.key, required this.address});

  final CustomerAddressEntity address;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.field.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.rose.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.sage.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 20,
              color: AppColors.sage,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Destination',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.clay,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  address.addressLine1,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  AddressOptionCard.formatAddress(address),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.muted,
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