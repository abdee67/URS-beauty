import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/core/widgets/retry_button.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart';
import 'package:urs_beauty/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:urs_beauty/features/bookings/presentation/screens/booking_reschedule_page.dart';
import 'package:urs_beauty/features/bookings/presentation/widgets/booking_list.dart';
import 'package:urs_beauty/features/bookings/presentation/widgets/booking_tab.dart';
import 'package:urs_beauty/features/reviews/domain/entity/review_entity.dart';
import 'package:urs_beauty/features/reviews/presentation/bloc/review_bloc.dart';
import 'package:urs_beauty/features/reviews/presentation/bloc/review_state.dart';
import 'package:urs_beauty/features/reviews/presentation/screens/write_review_screen.dart';
import 'package:urs_beauty/features/stylists/presentation/bloc/bloc/stylists_bloc.dart';
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
                final reviewsByBookingId = {
                  for (final review in reviewState.customerReviews)
                    review.bookingId: review,
                };
                final upcomingBookings = _sortUpcoming(bookings);
                final completedBookings = _sortCompleted(
                  bookings,
                  reviewsByBookingId,
                );
                final historyBookings = _sortHistory(
                  bookings,
                  reviewsByBookingId,
                );
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
                          ? RetryButton(
                              message: bookingState.errorMessage,
                              onRetry: _reloadBookings,
                            )
                          : TabBarView(
                              children: [
                                BookingTabContent(
                                  bookings: upcomingBookings,
                                  emptyTitle: 'No upcoming bookings yet',
                                  emptySubtitle:
                                      'Your scheduled appointments will appear here.',
                                  onRefresh: _reloadBookings,
                                  itemBuilder: (booking) => BookingListItem(
                                    booking: booking,
                                    isBusy:
                                        bookingState.status ==
                                        BookingBlocStatus.cancelling,
                                    onCancel: () =>
                                        _confirmCancellation(booking),
                                    onReschedule: () =>
                                        _openRescheduleFlow(booking),
                                  ),
                                ),
                                BookingTabContent(
                                  bookings: completedBookings,
                                  emptyTitle: 'No completed bookings yet',
                                  emptySubtitle:
                                      'Completed appointments show up here so you can leave a review.',
                                  onRefresh: _reloadBookings,
                                  itemBuilder: (booking) => BookingListItem(
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
                                BookingTabContent(
                                  bookings: historyBookings,
                                  emptyTitle:
                                      'No Completed/Passed/Cancelled bookings yet',
                                  emptySubtitle:
                                      'Completed,Cancelled or older unfinished appointments will appear here.',
                                  onRefresh: _reloadBookings,
                                  itemBuilder: (booking) => BookingListItem(
                                    booking: booking,
                                    isHistory: true,
                                    review: reviewsByBookingId[booking.id],
                                    onReschedule: () =>
                                        _openRescheduleFlow(booking),
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

  Future<void> _openRescheduleFlow(BookingEntity booking) async {
    final rescheduled = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getit<BookingBloc>()),
            BlocProvider(create: (_) => getit<StylistsBloc>()),
          ],
          child: BookingReschedulePage(booking: booking),
        ),
      ),
    );

    if (rescheduled != true || !mounted) {
      return;
    }

    await _reloadBookings();
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Booking rescheduled successfully.')),
      );
  }

  List<BookingEntity> _sortUpcoming(List<BookingEntity> bookings) {
    final now = DateTime.now();
    final filtered = bookings.where((booking) {
      return _isScheduled(booking.status) && !booking.scheduledAt.isBefore(now);
    }).toList();

    filtered.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return filtered;
  }

  List<BookingEntity> _sortCompleted(
    List<BookingEntity> bookings,
    Map<String, ReviewEntity> reviewsByBookingId,
  ) {
    final filtered = bookings
        .where(
          (booking) =>
              booking.status == BookingStatus.completed &&
              !_hasReview(booking, reviewsByBookingId),
        )
        .toList();

    filtered.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    return filtered;
  }

  List<BookingEntity> _sortHistory(
    List<BookingEntity> bookings,
    Map<String, ReviewEntity> reviewsByBookingId,
  ) {
    final filtered = bookings.where((booking) {
      return (booking.status == BookingStatus.completed &&
              _hasReview(booking, reviewsByBookingId)) ||
          booking.status == BookingStatus.cancelled ||
          booking.status == BookingStatus.noShow;
    }).toList();

    filtered.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    return filtered;
  }

  bool _isScheduled(BookingStatus status) {
    return status == BookingStatus.pending;
  }

  bool _hasReview(
    BookingEntity booking,
    Map<String, ReviewEntity> reviewsByBookingId,
  ) {
    return booking.isReviewed || reviewsByBookingId.containsKey(booking.id);
  }
}
