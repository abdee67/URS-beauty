import 'package:flutter/material.dart';

class ReviewForm extends StatelessWidget {
  const ReviewForm({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    required this.commentController,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final double rating;
  final ValueChanged<double> onRatingChanged;
  final TextEditingController commentController;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final hasSelectedRating = rating >= 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your rating',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF43261D),
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap a star from 1 to 5. Ratings are only available after a completed booking.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF7B6156),
                height: 1.4,
              ),
        ),
        const SizedBox(height: 16),
        _InteractiveStarRow(
          rating: rating,
          onRatingChanged: onRatingChanged,
        ),
        const SizedBox(height: 24),
        Text(
          'Comment',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF43261D),
              ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: commentController,
          minLines: 4,
          maxLines: 6,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: 'Share what stood out about the service.',
            filled: true,
            fillColor: const Color(0xFFFFF8F2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFE9D5C8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFE9D5C8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFF6B3F32), width: 1.4),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: hasSelectedRating && !isSubmitting ? onSubmit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B3F32),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFDABFB2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Submit Review'),
          ),
        ),
      ],
    );
  }
}

class _InteractiveStarRow extends StatelessWidget {
  const _InteractiveStarRow({
    required this.rating,
    required this.onRatingChanged,
  });

  final double rating;
  final ValueChanged<double> onRatingChanged;

  @override
  Widget build(BuildContext context) {
    final selectedRating = rating.round().clamp(0, 5);

    return Row(
      children: List.generate(
        5,
        (index) {
          final starValue = index + 1;
          final isSelected = starValue <= selectedRating;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => onRatingChanged(starValue.toDouble()),
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                  color: const Color(0xFFF2A33A),
                  size: 36,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
