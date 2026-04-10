import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:urs_beauty/features/bookings/presentation/screens/booking_schedule_screen.dart';
import 'package:urs_beauty/features/reviews/domain/entity/review_entity.dart';
import 'package:urs_beauty/features/reviews/presentation/bloc/review_bloc.dart';
import 'package:urs_beauty/features/reviews/presentation/bloc/review_state.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';
import 'package:urs_beauty/injection_container.dart';

class StylistProfileScreen extends StatefulWidget {
  const StylistProfileScreen({
    super.key,
    required this.stylist,
    this.serviceId,
    this.serviceName,
  });

  final Stylist stylist;
  final String? serviceId;
  final String? serviceName;

  @override
  State<StylistProfileScreen> createState() => _StylistProfileScreenState();
}

class _StylistProfileScreenState extends State<StylistProfileScreen> {
  DateTime? _lastRefreshAt;
  bool _refreshQueued = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getit<ReviewBloc>()
        ..add(GetReviewsByStylistIdEvent(widget.stylist.id))
        ..add(GetRatingSummaryEvent(widget.stylist.id)),
      child: _StylistProfileView(
        stylist: widget.stylist,
        serviceId: widget.serviceId,
        serviceName: widget.serviceName,
        onRefreshMark: _queueRefreshIfStale,
      ),
    );
  }

  void _queueRefreshIfStale(BuildContext context, ReviewState state) {
    if (_refreshQueued) {
      return;
    }

    final isBusy =
        state.status == ReviewBlocStatus.loading ||
        state.status == ReviewBlocStatus.ratingLoading;
    if (isBusy) {
      return;
    }

    final now = DateTime.now();
    final recentlyRefreshed =
        _lastRefreshAt != null &&
        now.difference(_lastRefreshAt!) < const Duration(seconds: 5);

    if (recentlyRefreshed) {
      return;
    }

    _refreshQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _lastRefreshAt = DateTime.now();
      _refreshQueued = false;
      context.read<ReviewBloc>().add(
        GetReviewsByStylistIdEvent(widget.stylist.id),
      );
      context.read<ReviewBloc>().add(GetRatingSummaryEvent(widget.stylist.id));
    });
  }
}

class _StylistProfileView extends StatelessWidget {
  const _StylistProfileView({
    required this.stylist,
    this.serviceId,
    this.serviceName,
    required this.onRefreshMark,
  });

  final Stylist stylist;
  final String? serviceId;
  final String? serviceName;
  final void Function(BuildContext context, ReviewState state) onRefreshMark;

  bool get _canBook => serviceId?.trim().isNotEmpty == true;

  String get _resolvedServiceName {
    if (serviceName?.trim().isNotEmpty == true) {
      return serviceName!.trim();
    }
    return 'Selected service';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReviewBloc, ReviewState>(
      builder: (context, state) {
        onRefreshMark(context, state);

        final reviews = state.stylistReviews;
        final isLoadingReviews =
            state.status == ReviewBlocStatus.loading && reviews.isEmpty;

        return Scaffold(
          backgroundColor: const Color(0xFFFFFBF6),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFF7F0), Color(0xFFFFE5D2)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              _ProfileHeroCard(stylist: stylist),
                              const SizedBox(height: 18),
                              _RatingSummaryCard(
                                averageRating: stylist.averageRating,
                                totalReviews: stylist.totalReview,
                              ),
                              const SizedBox(height: 18),
                              _SectionHeader(
                                title: 'Reviews',
                                subtitle:
                                    'Recent feedback from completed appointments.',
                              ),
                              const SizedBox(height: 12),
                              if (isLoadingReviews)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              else if (reviews.isEmpty)
                                const _EmptyReviewsState()
                              else
                                ...reviews.map((review) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _ReviewListItem(review: review),
                                  );
                                }),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ?_canBook
                      ? Container(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                          child: _canBook
                              ? SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => _openBookingFlow(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6B3F32),
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: const Color(
                                        0xFFD8C0B5,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Book $_resolvedServiceName',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                              : null,
                        )
                      : null,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openBookingFlow(BuildContext context) {
    final resolvedServiceId = serviceId?.trim();
    if (resolvedServiceId == null || resolvedServiceId.isEmpty) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => getit<BookingBloc>(),
          child: BookingScheduleScreen(
            serviceId: resolvedServiceId,
            serviceName: _resolvedServiceName,
            stylist: stylist,
          ),
        ),
      ),
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({required this.stylist});

  final Stylist stylist;

  @override
  Widget build(BuildContext context) {
    final hasImage = stylist.imageUrl.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF6B3F32),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: const Color(0xFFFFE7D5),
                backgroundImage: hasImage
                    ? NetworkImage(stylist.imageUrl)
                    : null,
                child: hasImage
                    ? null
                    : const Icon(
                        Icons.face_rounded,
                        color: Color(0xFFC96A3D),
                        size: 34,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stylist.businessName,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      stylist.isVerified
                          ? 'Verified stylist'
                          : 'Independent stylist',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFFFFDFC9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            stylist.description.trim().isEmpty
                ? 'Professional beauty services with a focus on client care.'
                : stylist.description,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.white, height: 1.45),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _HeroStat(
                icon: Icons.place_outlined,
                label:
                    '${stylist.serviceRadiusKm.toStringAsFixed(0)} km radius',
              ),
              const SizedBox(width: 12),
              _HeroStat(
                icon: Icons.verified_outlined,
                label: stylist.isVerified ? 'Verified' : 'Not verified',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFFFD6BA)),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingSummaryCard extends StatelessWidget {
  const _RatingSummaryCard({
    required this.averageRating,
    required this.totalReviews,
  });

  final double averageRating;
  final int totalReviews;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0D8CA)),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3D9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.star_rounded,
              color: Color(0xFFF2A33A),
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  averageRating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF43261D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '($totalReviews reviews)',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF7B6156),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF43261D),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF7B6156),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _ReviewListItem extends StatelessWidget {
  const _ReviewListItem({required this.review});

  final ReviewEntity review;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final filledStars = review.rating.round().clamp(0, 5);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF0D8CA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFF7E7DA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Color(0xFF9E735F),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Anonymous customer',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF43261D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < filledStars
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: const Color(0xFFF2A33A),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
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
          const SizedBox(height: 12),
          Text(
            review.hasComment
                ? review.comment!.trim()
                : 'This customer left a rating without a written comment.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5C4035),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyReviewsState extends StatelessWidget {
  const _EmptyReviewsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0D8CA)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.rate_review_outlined,
            color: Color(0xFF9E735F),
            size: 34,
          ),
          const SizedBox(height: 12),
          Text(
            'No reviews yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF43261D),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Completed bookings will start showing feedback here once customers leave reviews.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF7B6156),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
