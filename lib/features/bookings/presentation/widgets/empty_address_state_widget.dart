import 'package:flutter/material.dart';
import 'package:urs_beauty/core/constants/app_colors.dart';

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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.clay.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.field,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.rose.withValues(alpha: 0.5)),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              size: 32,
              color: AppColors.clay,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No saved address yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Use your current location and we will save it for this appointment.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isBusy ? null : onUseCurrentLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.clay,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: isBusy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.my_location_rounded, size: 20),
              label: Text(
                isBusy ? 'Getting location...' : 'Use current location',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}