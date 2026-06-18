import 'package:flutter/material.dart';
import 'package:urs_beauty/core/widgets/info_chip.dart';
import 'package:urs_beauty/features/beauty_services/domain/entities/service_entity.dart';

class ServiceTile extends StatelessWidget {
  const ServiceTile({super.key, required this.service, required this.onTap});

  final ServiceEntity service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.spa_rounded, color: Color(0xFFC96A3D)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      service.description.isEmpty
                          ? 'Professional service available for booking.'
                          : service.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        InfoChip(
                          label: _formatPrice(
                            service.minPrice,
                            service.basePrice,
                          ),
                        ),
                        InfoChip(
                          label: _formatDuration(service.durationMinutes),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(double minPrice, double basePrice) {
    final price = minPrice > 0 ? minPrice : basePrice;
    if (price <= 0) {
      return 'Price on request';
    }
    if (minPrice > 0 && basePrice > minPrice) {
      return 'From ${price.toStringAsFixed(0)}';
    }
    return price.toStringAsFixed(0);
  }

  String _formatDuration(int? durationMinutes) {
    if (durationMinutes == null || durationMinutes <= 0) {
      return 'Flexible time';
    }
    return '$durationMinutes min';
  }
}
