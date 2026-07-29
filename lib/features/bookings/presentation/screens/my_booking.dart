import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/core/constants/app_colors.dart';
import 'package:urs_beauty/core/widgets/retry_button.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart';
import 'package:urs_beauty/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:urs_beauty/features/bookings/presentation/screens/booking_reschedule_page.dart';
import 'package:urs_beauty/features/bookings/presentation/widgets/booking_list.dart';
import 'package:urs_beauty/features/bookings/presentation/widgets/booking_tab.dart';
import 'package:urs_beauty/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:urs_beauty/features/payments/presentation/screens/payment_methods_screen.dart';
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

class _MyBookingScreenState extends State<MyBookingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _loadedReviewsForCustomerId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load bookings on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BookingBloc>().add(const LoadMyBookingsEvent());
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _reloadBookings() async {
    context.read<BookingBloc>().add(const LoadMyBookingsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<BookingBloc, BookingState>(
          listener: _onBookingStateChanged,
        ),
        BlocListener<ReviewBloc, ReviewState>(listener: _onReviewStateChanged),
      ],
      child: Scaffold(
        backgroundColor: AppColors.blush,
        appBar: AppBar(
          title: Text(
            'My Bookings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          bottom: _buildModernTabBar(),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.paper, Color(0xFFFFF0E6)],
            ),
          ),
          child: BlocBuilder<BookingBloc, BookingState>(
            builder: (context, bookingState) {
              return BlocBuilder<ReviewBloc, ReviewState>(
                builder: (context, reviewState) {
                  final bookings = bookingState.customerBookings;
                  final reviewsByBookingId = {
                    for (final review in reviewState.customerReviews)
                      review.bookingId: review,
                  };
                  final upcoming = _sortUpcoming(bookings);
                  final completed = _sortCompleted(
                    bookings,
                    reviewsByBookingId,
                  );
                  final history = _sortHistory(bookings, reviewsByBookingId);
                  final isLoadingInitial =
                      bookingState.status == BookingBlocStatus.loading &&
                      bookings.isEmpty;
                  final hasInitialError =
                      bookingState.status == BookingBlocStatus.failure &&
                      bookings.isEmpty;

                  if (isLoadingInitial) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.clay),
                    );
                  }
                  if (hasInitialError) {
                    return RetryButton(
                      message: bookingState.errorMessage,
                      onRetry: _reloadBookings,
                    );
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      BookingTabContent(
                        bookings: upcoming,
                        emptyTitle: 'No upcoming bookings',
                        emptySubtitle:
                            'Your scheduled appointments will appear here.',
                        onRefresh: _reloadBookings,
                        itemBuilder: (booking) => BookingListItem(
                          booking: booking,
                          isBusy:
                              bookingState.status ==
                              BookingBlocStatus.cancelling,
                          onCancel: () => _confirmCancellation(booking),
                          onReschedule: () => _openRescheduleFlow(booking),
                        ),
                      ),
                      BookingTabContent(
                        bookings: completed,
                        emptyTitle: 'No completed bookings yet',
                        emptySubtitle:
                            'Completed appointments show up here so you can pay after service and leave a review.',
                        onRefresh: _reloadBookings,
                        itemBuilder: (booking) => BookingListItem(
                          booking: booking,
                          isCompleted: true,
                          review: reviewsByBookingId[booking.id],
                          onPayNow: booking.canCollectPostServicePayment
                              ? () => _openPaymentFlow(booking)
                              : null,
                          onReviewTap: () => _openReviewFlow(
                            booking,
                            existingReview: reviewsByBookingId[booking.id],
                          ),
                        ),
                      ),
                      BookingTabContent(
                        bookings: history,
                        emptyTitle: 'No history',
                        emptySubtitle:
                            'Completed, cancelled or older appointments will appear here.',
                        onRefresh: _reloadBookings,
                        itemBuilder: (booking) => BookingListItem(
                          booking: booking,
                          isHistory: true,
                          review: reviewsByBookingId[booking.id],
                          onReschedule: () => _openRescheduleFlow(booking),
                          onReviewTap: () => _openReviewFlow(
                            booking,
                            existingReview: reviewsByBookingId[booking.id],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── Modern Tab Bar ─────────────────────────────────────────────────────
  PreferredSizeWidget _buildModernTabBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: AppColors.clay.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          //padding: const EdgeInsets.all(4),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.clay, AppColors.clay],
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.muted,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
              Tab(text: 'History'),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Bloc Listeners ─────────────────────────────────────────────────────
  void _onBookingStateChanged(BuildContext context, BookingState state) {
    // Load reviews when customer ID is available
    final customerId = state.customer?.id;
    if (customerId != null && customerId != _loadedReviewsForCustomerId) {
      _loadedReviewsForCustomerId = customerId;
      context.read<ReviewBloc>().add(GetReviewsByCustomerIdEvent(customerId));
    }

    // Show feedback for cancellation or failure
    if ((state.status == BookingBlocStatus.cancelled ||
            state.status == BookingBlocStatus.failure) &&
        (state.message?.isNotEmpty == true || state.errorMessage.isNotEmpty)) {
      final message = state.status == BookingBlocStatus.failure
          ? state.errorMessage
          : (state.message ?? '');
      _showSnackbar(message);
    }
  }

  void _onReviewStateChanged(BuildContext context, ReviewState state) {
    if (state.status == ReviewBlocStatus.failure &&
        state.errorMessage.isNotEmpty) {
      _showSnackbar(state.errorMessage);
    }
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // ─── Booking Actions ────────────────────────────────────────────────────
  Future<void> _confirmCancellation(BookingEntity booking) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel booking?'),
        content: Text(
          'This will cancel your ${booking.serviceName.isNotEmpty ? booking.serviceName : 'appointment'} '
          'scheduled for ${_formatDate(booking.scheduledAt)}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Keep', style: TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.clay,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancel booking'),
          ),
        ],
      ),
    );

    if (shouldCancel == true && mounted) {
      context.read<BookingBloc>().add(CancelBookingEvent(booking.id));
    }
  }

  Future<void> _openReviewFlow(
    BookingEntity booking, {
    ReviewEntity? existingReview,
  }) async {
    final submitted = await Navigator.of(context).push<ReviewEntity>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getit<ReviewBloc>(),
          child: WriteReviewScreen(
            booking: booking,
            initialReview: existingReview,
          ),
        ),
      ),
    );

    if (!mounted) return;

    final customerId = booking.customerId;
    // Refresh bookings and reviews after submitting
    if (submitted != null) {
      _reloadBookings();
      if (!mounted) return;
      context.read<ReviewBloc>().add(GetReviewsByCustomerIdEvent(customerId));
      if (existingReview == null) {
        _showSnackbar('Review submitted successfully.');
      }
    }
  }

  Future<void> _openPaymentFlow(BookingEntity booking) async {
    final paid = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getit<PaymentBloc>(),
          child: PaymentMethodsScreen(
            booking: booking,
            serviceName: booking.serviceName,
            stylistName: booking.stylistName,
          ),
        ),
      ),
    );

    if (!mounted) return;

    if (paid == true) {
      _showSnackbar('Payment completed successfully.');
    }
    _reloadBookings();
  }

  Future<void> _openRescheduleFlow(BookingEntity booking) async {
    final rescheduled = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getit<BookingBloc>()),
            BlocProvider(create: (_) => getit<StylistsBloc>()),
          ],
          child: BookingReschedulePage(booking: booking),
        ),
      ),
    );

    if (!mounted) return;

    if (rescheduled == true) {
      _reloadBookings();
      if (!mounted) return;
      _showSnackbar('Booking rescheduled successfully.');
    }
  }

  // ─── Helper Methods ─────────────────────────────────────────────────────
  String _formatDate(DateTime date) {
    // Use a simple locale-independent format
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  List<BookingEntity> _sortUpcoming(List<BookingEntity> bookings) {
    final now = DateTime.now();
    return bookings
        .where((b) => _isScheduled(b.status) && !b.scheduledAt.isBefore(now))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  List<BookingEntity> _sortCompleted(
    List<BookingEntity> bookings,
    Map<String, ReviewEntity> reviewsByBookingId,
  ) {
    return bookings
        .where(
          (b) =>
              b.status == BookingStatus.completed &&
              (b.canCollectPostServicePayment ||
                  b.isPaymentAwaitingVerification ||
                  !_hasReview(b, reviewsByBookingId)),
        )
        .toList()
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
  }

  List<BookingEntity> _sortHistory(
    List<BookingEntity> bookings,
    Map<String, ReviewEntity> reviewsByBookingId,
  ) {
    return bookings
        .where(
          (b) =>
              (b.status == BookingStatus.completed &&
                  _hasReview(b, reviewsByBookingId) &&
                  !b.canCollectPostServicePayment &&
                  !b.isPaymentAwaitingVerification) ||
              b.status == BookingStatus.cancelled ||
              b.status == BookingStatus.noShow,
        )
        .toList()
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
  }

  bool _isScheduled(BookingStatus status) =>
      status == BookingStatus.pending ||
      status == BookingStatus.inProgress ||
      status == BookingStatus.confirmed;

  bool _hasReview(
    BookingEntity booking,
    Map<String, ReviewEntity> reviewsByBookingId,
  ) => booking.isReviewed || reviewsByBookingId.containsKey(booking.id);
}
