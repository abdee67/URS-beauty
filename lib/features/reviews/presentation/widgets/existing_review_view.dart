import 'package:flutter/material.dart';
import 'package:urs_beauty/features/bookings/presentation/widgets/star_row.dart';
import 'package:urs_beauty/features/reviews/domain/entity/review_entity.dart';

class ExistingReviewView extends StatelessWidget {
  const ExistingReviewView({super.key, required this.review});

  final ReviewEntity review;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.verified_rounded, color: Color(0xFF287A4B)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Review already submitted',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF43261D),
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Only one review is allowed per completed booking.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF7B6156),
                height: 1.4,
              ),
        ),
        const SizedBox(height: 18),
      StarRow(rating: review.rating),
        const SizedBox(height: 12),
        Text(
          localizations.formatFullDate(review.createdAt),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF8E7266),
              ),
        ),
        if (review.hasComment) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8F2),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE9D5C8)),
            ),
            child: Text(
              review.comment!.trim(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5C4035),
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ],
    );
  }
}
