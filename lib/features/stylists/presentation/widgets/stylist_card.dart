import 'package:flutter/material.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';
import 'package:urs_beauty/features/stylists/presentation/widgets/distance_badge.dart';
import 'package:urs_beauty/features/stylists/presentation/widgets/stylist_avatar.dart';

class StylistCard extends StatelessWidget {
  const StylistCard({
    super.key,
    required this.stylist,
    required this.onTap,
    this.distanceKm,
  });

  final Stylist stylist;
  final VoidCallback onTap;
  final double? distanceKm;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withAlpha(230),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              StylistAvatar(imageUrl: stylist.imageUrl),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stylist.businessName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2F1C18),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stylist.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              stylist.averageRating.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Text(
                          '${stylist.totalReview} reviews',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                        if (distanceKm != null)
                          DistanceBadge(distanceKm: distanceKm!),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to view profile, ratings, and recent reviews.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8A6A5C),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
