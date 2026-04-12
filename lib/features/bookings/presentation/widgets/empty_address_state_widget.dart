import 'package:flutter/material.dart';

class AddressEmptyState extends StatelessWidget {
  const AddressEmptyState({
    super.key,
    required this.isBusy,
    required this.onUseCurrentLocation,
  });

  final bool isBusy;
  final VoidCallback onUseCurrentLocation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(220),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No saved address yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF43261D),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use your current location and we will save it as a customer address for this booking.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF7C5342),
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: isBusy ? null : onUseCurrentLocation,
            icon: isBusy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location_rounded),
            label: Text(
              isBusy ? 'Getting location...' : 'Use current location',
            ),
          ),
        ],
      ),
    );
  }
}