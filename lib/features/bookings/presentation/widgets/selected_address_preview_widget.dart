import 'package:flutter/material.dart';
import 'package:urs_beauty/features/auth/data/models/customer_address_model.dart';
import 'package:urs_beauty/features/bookings/presentation/widgets/address_option_card_widget.dart';

class SelectedAddressPreview extends StatelessWidget {
  const SelectedAddressPreview({super.key, required this.address});

  final CustomerAddressModel address;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(220),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected address',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF7C5342),
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            address.addressLine1,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF43261D),
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            AddressOptionCard.formatAddress(address),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF7C5342),
                ),
          ),
        ],
      ),
    );
  }
}