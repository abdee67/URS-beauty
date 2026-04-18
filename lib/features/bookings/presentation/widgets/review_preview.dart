import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:urs_beauty/features/bookings/presentation/widgets/star_row.dart';
import 'package:urs_beauty/features/reviews/domain/entity/review_entity.dart';

class ReviewPreview extends StatelessWidget {
  const ReviewPreview({super.key, required this.review, this.onOpen});

  final ReviewEntity review;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6EE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0D8CA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rate_review_rounded, color: Color(0xFF8C533D)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your review',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF43261D),
                  ),
                ),
              ),
              Text(
                localizations.formatShortDate(review.createdAt),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: const Color(0xFF8E7266)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          StarRow(rating: review.rating),
          if (review.hasComment) ...[
            const SizedBox(height: 10),
            Text(
              review.comment!.trim(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF5C4035),
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.visibility_rounded),
            label: const Text('View Review'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6B3F32),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}