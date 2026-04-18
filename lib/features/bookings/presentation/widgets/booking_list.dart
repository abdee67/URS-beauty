import 'package:flutter/material.dart';
import 'package:urs_beauty/core/widgets/meta_row.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart';
import 'package:urs_beauty/features/bookings/presentation/widgets/booking_status_badge.dart';
import 'package:urs_beauty/features/bookings/presentation/widgets/review_preview.dart';
import 'package:urs_beauty/features/reviews/domain/entity/review_entity.dart';

class BookingListItem extends StatelessWidget {
  const BookingListItem({
    super.key,
    required this.booking,
    this.isHistory = false,
    this.isCompleted = false,
    this.isBusy = false,
    this.onCancel,
    this.onReschedule,
    this.review,
    this.onReviewTap,
  });

  final BookingEntity booking;
  final bool isHistory;
  final bool isCompleted;
  final bool isBusy;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;
  final ReviewEntity? review;
  final VoidCallback? onReviewTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);
    final formattedDate =
        '${localizations.formatMediumDate(booking.scheduledAt)} at '
        '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(booking.scheduledAt))}';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF0D8CA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.serviceName.isEmpty
                          ? 'Beauty service'
                          : booking.serviceName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF43261D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      booking.stylistName.isEmpty
                          ? 'Assigned stylist'
                          : booking.stylistName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF7B6156),
                      ),
                    ),
                  ],
                ),
              ),
              BookingStatusBadge(
                status: booking.status,
                isReviewed: booking.isReviewed,
              ),
            ],
          ),
          const SizedBox(height: 16),
          MetaRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date & time',
            value: formattedDate,
          ),
          if ((booking.notes ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            MetaRow(
              icon: Icons.sticky_note_2_outlined,
              label: 'Notes',
              value: booking.notes!.trim(),
            ),
          ],
          if (isHistory) ...[
            const SizedBox(height: 18),
            if (review != null &&
                booking.status == BookingStatus.completed &&
                booking.isReviewed == true)
              ReviewPreview(review: review!, onOpen: onReviewTap)
            else if (booking.status == BookingStatus.cancelled ||
                booking.status == BookingStatus.noShow)
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8EFE7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      booking.status == BookingStatus.noShow
                          ? 'You missed this appointment.'
                          : 'This booking was cancelled.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF7B6156),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onReschedule,
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('Reschedule'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFF8EFE7),
                        foregroundColor: const Color(0xFF6B3F32),
                        side: const BorderSide(color: Color(0xFFD8C0B5)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ]
          //for completed and not history
          else if (isCompleted) ...[
            if (booking.status == BookingStatus.completed &&
                booking.isReviewed == false) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onReviewTap,
                  icon: const Icon(Icons.star_rounded),
                  label: const Text('Leave Review'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B3F32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ] else if (!isCompleted && !isHistory) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isBusy ? null : onCancel,
                    icon: isBusy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.close_rounded),
                    label: const Text('Cancel booking'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF9B3D2E),
                      side: const BorderSide(color: Color(0xFFE2B7B0)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReschedule,
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: const Text('Reschedule'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6B3F32),
                      side: const BorderSide(color: Color(0xFFD8C0B5)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
