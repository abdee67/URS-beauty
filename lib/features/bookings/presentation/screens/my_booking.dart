import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart';
import 'package:urs_beauty/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:urs_beauty/features/bookings/presentation/widgets/booking_error_widget.dart';
import 'package:urs_beauty/features/reviews/domain/entity/review_entity.dart';
import 'package:urs_beauty/features/reviews/presentation/bloc/review_bloc.dart';
import 'package:urs_beauty/features/reviews/presentation/bloc/review_state.dart';
import 'package:urs_beauty/features/reviews/presentation/screens/write_review_screen.dart';
import 'package:urs_beauty/injection_container.dart';

class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({super.key});

  @override
  State<MyBookingScreen> createState() => _MyBookingScreenState();
}

class _MyBookingScreenState extends State<MyBookingScreen> {
  String? _loadedReviewsForCustomerId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) {
        return;
      }
      context.read<BookingBloc>().add(const LoadMyBookingsEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: MultiBlocListener(
        listeners: [
          BlocListener<BookingBloc, BookingState>(
            listener: (context, state) {
              final customerId = state.customer?.id;
              if (customerId != null &&
                  customerId != _loadedReviewsForCustomerId) {
                _loadedReviewsForCustomerId = customerId;
                context.read<ReviewBloc>().add(
                  GetReviewsByCustomerIdEvent(customerId),
                );
              }

              if ((state.status == BookingBlocStatus.cancelled ||
                      state.status == BookingBlocStatus.failure) &&
                  (state.message?.isNotEmpty == true ||
                      state.errorMessage.isNotEmpty)) {
                final message = state.status == BookingBlocStatus.failure
                    ? state.errorMessage
                    : (state.message ?? '');
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(message)));
              }
            },
          ),
          BlocListener<ReviewBloc, ReviewState>(
            listener: (context, state) {
              if (state.status == ReviewBlocStatus.failure &&
                  state.errorMessage.isNotEmpty) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(state.errorMessage)));
              }
            },
          ),
        ],
        child: BlocBuilder<BookingBloc, BookingState>(
          builder: (context, bookingState) {
            return BlocBuilder<ReviewBloc, ReviewState>(
              builder: (context, reviewState) {
                final bookings = bookingState.customerBookings;
                final upcomingBookings = _sortUpcoming(bookings);
                final completedBookings = _sortCompleted(bookings);
                final historyBookings = _sortHistory(bookings);
                final reviewsByBookingId = {
                  for (final review in reviewState.customerReviews)
                    review.bookingId: review,
                };
                final isInitialLoading =
                    bookingState.status == BookingBlocStatus.loading &&
                    bookings.isEmpty;
                final hasInitialFailure =
                    bookingState.status == BookingBlocStatus.failure &&
                    bookings.isEmpty;

                return Scaffold(
                  backgroundColor: const Color(0xFFFFFBF6),
                  appBar: AppBar(
                    elevation: 0,
                    backgroundColor: const Color(0xFFFFFBF6),
                    surfaceTintColor: Colors.transparent,
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(20),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7E7DA),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TabBar(
                            indicator: BoxDecoration(
                              color: const Color(0xFF6B3F32),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            dividerColor: Colors.transparent,
                            labelColor: Colors.white,
                            unselectedLabelColor: const Color(0xFF7B6156),
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                            tabs: const [
                              Tab(text: 'Upcoming'),
                              Tab(text: 'Completed'),
                              Tab(text: 'History'),
                            ],
                          ),
                        ),
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
                      child: isInitialLoading
                          ? const Center(child: CircularProgressIndicator())
                          : hasInitialFailure
                          ? _RetryState(
                              message: bookingState.errorMessage,
                              onRetry: _reloadBookings,
                            )
                          : TabBarView(
                              children: [
                                _BookingTabContent(
                                  bookings: upcomingBookings,
                                  emptyTitle: 'No upcoming bookings yet',
                                  emptySubtitle:
                                      'Your scheduled appointments will appear here.',
                                  onRefresh: _reloadBookings,
                                  itemBuilder: (booking) => _BookingListItem(
                                    booking: booking,
                                    isBusy:
                                        bookingState.status ==
                                        BookingBlocStatus.cancelling,
                                    onCancel: () =>
                                        _confirmCancellation(booking),
                                    onReschedule: () {
                                      ScaffoldMessenger.of(context)
                                        ..hideCurrentSnackBar()
                                        ..showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Reschedule will be available soon.',
                                            ),
                                          ),
                                        );
                                    },
                                  ),
                                ),
                                _BookingTabContent(
                                  bookings: completedBookings,
                                  emptyTitle: 'No completed bookings yet',
                                  emptySubtitle:
                                      'Completed appointments show up here so you can leave a review.',
                                  onRefresh: _reloadBookings,
                                  itemBuilder: (booking) => _BookingListItem(
                                    booking: booking,
                                    isCompleted: true,
                                    review: reviewsByBookingId[booking.id],
                                    onReviewTap: () => _openReviewFlow(
                                      booking,
                                      existingReview:
                                          reviewsByBookingId[booking.id],
                                    ),
                                  ),
                                ),
                                _BookingTabContent(
                                  bookings: historyBookings,
                                  emptyTitle:
                                      'No Confirmed/Passed/Cancelled bookings yet',
                                  emptySubtitle:
                                      'Confirmed,Cancelled or older unfinished appointments will appear here.',
                                  onRefresh: _reloadBookings,
                                  itemBuilder: (booking) => _BookingListItem(
                                    booking: booking,
                                    isHistory: true,
                                    review: reviewsByBookingId[booking.id],
                                    onReviewTap: () => _openReviewFlow(
                                      booking,
                                      existingReview:
                                          reviewsByBookingId[booking.id],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _reloadBookings() async {
    context.read<BookingBloc>().add(const LoadMyBookingsEvent());
  }

  Future<void> _confirmCancellation(BookingEntity booking) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel booking?'),
          content: Text(
            'This will cancel ${booking.serviceName.isEmpty ? 'this appointment' : booking.serviceName} '
            'scheduled for ${MaterialLocalizations.of(context).formatMediumDate(booking.scheduledAt)}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B3D2E),
                foregroundColor: Colors.white,
              ),
              child: const Text('Cancel booking'),
            ),
          ],
        );
      },
    );

    if (shouldCancel == true && mounted) {
      context.read<BookingBloc>().add(CancelBookingEvent(booking.id));
    }
  }

  Future<void> _openReviewFlow(
    BookingEntity booking, {
    ReviewEntity? existingReview,
  }) async {
    final bookingBloc = context.read<BookingBloc>();
    final reviewBloc = context.read<ReviewBloc>();
    final submittedReview = await Navigator.of(context).push<ReviewEntity>(
      MaterialPageRoute<ReviewEntity>(
        builder: (_) => BlocProvider(
          create: (_) => getit<ReviewBloc>(),
          child: WriteReviewScreen(
            booking: booking,
            initialReview: existingReview,
          ),
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    final customerId = bookingBloc.state.customer?.id ?? booking.customerId;
    if (submittedReview != null) {
      await _reloadBookings();
      if (!mounted) {
        return;
      }
    }
    reviewBloc.add(GetReviewsByCustomerIdEvent(customerId));

    if (submittedReview != null && existingReview == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Review submitted successfully.')),
        );
    }
  }

  List<BookingEntity> _sortUpcoming(List<BookingEntity> bookings) {
    final now = DateTime.now();
    final filtered = bookings.where((booking) {
      return _isScheduled(booking.status) && !booking.scheduledAt.isBefore(now);
    }).toList();

    filtered.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return filtered;
  }

  List<BookingEntity> _sortCompleted(List<BookingEntity> bookings) {
    final filtered = bookings
        .where((booking) => booking.status == BookingStatus.completed)
        .toList();

    filtered.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    return filtered;
  }

  List<BookingEntity> _sortHistory(List<BookingEntity> bookings) {
    final now = DateTime.now();
    final filtered = bookings.where((booking) {
      if (booking.status == BookingStatus.completed) {
        return false;
      }
      if (booking.status == BookingStatus.cancelled ||
          booking.status == BookingStatus.passed ||
          booking.status == BookingStatus.confirmed) {
        return true;
      }
      return booking.scheduledAt.isBefore(now);
    }).toList();

    filtered.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    return filtered;
  }

  bool _isScheduled(BookingStatus status) {
    return status == BookingStatus.pending;
  }
}

class _BookingTabContent extends StatelessWidget {
  const _BookingTabContent({
    required this.bookings,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onRefresh,
    required this.itemBuilder,
  });

  final List<BookingEntity> bookings;
  final String emptyTitle;
  final String emptySubtitle;
  final Future<void> Function() onRefresh;
  final Widget Function(BookingEntity booking) itemBuilder;

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 80),
            _EmptyBookingsState(title: emptyTitle, subtitle: emptySubtitle),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        itemBuilder: (context, index) => itemBuilder(bookings[index]),
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemCount: bookings.length,
      ),
    );
  }
}

class _BookingListItem extends StatelessWidget {
  const _BookingListItem({
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
              _StatusBadge(status: booking.status),
            ],
          ),
          const SizedBox(height: 16),
          _MetaRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date & time',
            value: formattedDate,
          ),
          if ((booking.notes ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _MetaRow(
              icon: Icons.sticky_note_2_outlined,
              label: 'Notes',
              value: booking.notes!.trim(),
            ),
          ],
          if (isHistory) ...[
            const SizedBox(height: 18),
            if (review != null && booking.status == BookingStatus.confirmed)
              _ReviewPreview(review: review!, onOpen: onReviewTap)
            else if (booking.status == BookingStatus.cancelled ||
                booking.status == BookingStatus.passed)
              //let user choose to reschedule or leave review
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onReschedule,
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('Reschedule'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B3F32),
                        foregroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
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
              ),
          ]
          //for completed and not history
          else if (isCompleted) ...[
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

class _ReviewPreview extends StatelessWidget {
  const _ReviewPreview({required this.review, this.onOpen});

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
          _StarRow(rating: review.rating),
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, background, foreground) = switch (status) {
      BookingStatus.confirmed => (
        'Confirmed',
        const Color(0xFFE6F5EB),
        const Color(0xFF287A4B),
      ),
      BookingStatus.completed => (
        'Completed',
        const Color(0xFFE6F5EB),
        const Color.fromARGB(255, 227, 131, 21),
      ),
      BookingStatus.passed => (
        'Passed',
        const Color(0xFFE6F5EB),
        const Color.fromARGB(255, 227, 210, 21),
      ),
      BookingStatus.cancelled => (
        'Cancelled',
        const Color(0xFFFBE9E7),
        const Color(0xFFB54432),
      ),
      _ => ('Scheduled', const Color(0xFFF5E8D9), const Color(0xFF7A4A39)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF9E735F)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: const Color(0xFF8E7266)),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF43261D),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final filledStars = rating.round().clamp(0, 5);

    return Row(
      children: List.generate(
        5,
        (index) => Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Icon(
            index < filledStars
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color: const Color(0xFFF2A33A),
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _EmptyBookingsState extends StatelessWidget {
  const _EmptyBookingsState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: Color(0xFFF5E8D9),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.event_note_rounded,
            color: Color(0xFF7A4A39),
            size: 34,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF43261D),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF7B6156),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _RetryState extends StatelessWidget {
  const _RetryState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BookingErrorState(message: message),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}
