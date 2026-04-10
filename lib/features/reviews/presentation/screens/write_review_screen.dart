import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart';
import 'package:urs_beauty/features/reviews/domain/entity/review_entity.dart';
import 'package:urs_beauty/features/reviews/presentation/bloc/review_bloc.dart';
import 'package:urs_beauty/features/reviews/presentation/bloc/review_state.dart';
import 'package:urs_beauty/features/reviews/presentation/widgets/review_form.dart';

class WriteReviewScreen extends StatefulWidget {
  const WriteReviewScreen({
    super.key,
    required this.booking,
    this.initialReview,
  });

  final BookingEntity booking;
  final ReviewEntity? initialReview;

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  late final TextEditingController _commentController;
  late ReviewEntity? _existingReview;
  double _selectedRating = 0;

  @override
  void initState() {
    super.initState();
    _existingReview = widget.initialReview;
    _commentController = TextEditingController(
      text: widget.initialReview?.comment?.trim() ?? '',
    );
    _selectedRating = widget.initialReview?.rating ?? 0;

    if (_existingReview == null) {
      Future.microtask(() {
        if (!mounted) {
          return;
        }
        context.read<ReviewBloc>().add(
          GetReviewByBookingIdEvent(widget.booking.id),
        );
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReviewBloc, ReviewState>(
      listener: (context, state) {
        if (state.status == ReviewBlocStatus.submitted &&
            state.selectedReview != null) {
          Navigator.of(context).pop(state.selectedReview);
          return;
        }

        if (state.status == ReviewBlocStatus.loaded) {
          setState(() {
            _existingReview = state.selectedReview;
            if (state.selectedReview != null) {
              _selectedRating = state.selectedReview!.rating;
              _commentController.text = state.selectedReview?.comment?.trim() ?? '';
            }
          });
        }

        if (state.status == ReviewBlocStatus.failure &&
            state.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage)));
        }
      },
      builder: (context, state) {
        final theme = Theme.of(context);
        final localizations = MaterialLocalizations.of(context);
        final isLoadingExistingReview =
            widget.initialReview == null &&
            state.status == ReviewBlocStatus.loading &&
            _existingReview == null;

        return Scaffold(
          backgroundColor: const Color(0xFFFFFBF6),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: const Color(0xFFFFFBF6),
            surfaceTintColor: Colors.transparent,
            title: Text(
              _existingReview == null ? 'Leave Review' : 'Your Review',
              style: const TextStyle(
                color: Color(0xFF43261D),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFF7F0), Color(0xFFFFE5D2)],
              ),
            ),
            child: SafeArea(
              top: false,
              child: isLoadingExistingReview
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _BookingSummaryCard(
                            booking: widget.booking,
                            formattedDate:
                                '${localizations.formatMediumDate(widget.booking.scheduledAt)} at '
                                '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(widget.booking.scheduledAt))}',
                          ),
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFFF0D8CA)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 18,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: _existingReview != null
                                ? _ExistingReviewView(review: _existingReview!)
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'How was your appointment?',
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF43261D),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Share your experience with ${widget.booking.stylistName.isEmpty ? 'your stylist' : widget.booking.stylistName}.',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: const Color(0xFF7B6156),
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      ReviewForm(
                                        rating: _selectedRating,
                                        onRatingChanged: (value) {
                                          setState(() {
                                            _selectedRating = value;
                                          });
                                        },
                                        commentController: _commentController,
                                        isSubmitting: state.status ==
                                            ReviewBlocStatus.submitting,
                                        onSubmit: _submitReview,
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  void _submitReview() {
    if (_selectedRating < 1) {
      return;
    }

    context.read<ReviewBloc>().add(
          SubmitReviewEvent(
            ReviewEntity(
              id: '',
              customerId: widget.booking.customerId,
              stylistId: widget.booking.stylistId,
              bookingId: widget.booking.id,
              rating: _selectedRating,
              comment: _commentController.text.trim(),
              createdAt: DateTime.now(),
            ),
          ),
        );
  }
}

class _BookingSummaryCard extends StatelessWidget {
  const _BookingSummaryCard({
    required this.booking,
    required this.formattedDate,
  });

  final BookingEntity booking;
  final String formattedDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF6B3F32),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            booking.serviceName.isEmpty ? 'Beauty service' : booking.serviceName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            booking.stylistName.isEmpty
                ? 'Assigned stylist'
                : booking.stylistName,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFFFFE6D5),
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: Color(0xFFFFD6BA),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  formattedDate,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExistingReviewView extends StatelessWidget {
  const _ExistingReviewView({required this.review});

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
        _ReadOnlyStarRow(rating: review.rating),
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

class _ReadOnlyStarRow extends StatelessWidget {
  const _ReadOnlyStarRow({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final filledStars = rating.round().clamp(0, 5);

    return Row(
      children: List.generate(
        5,
        (index) => Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Icon(
            index < filledStars
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color: const Color(0xFFF2A33A),
            size: 28,
          ),
        ),
      ),
    );
  }
}
