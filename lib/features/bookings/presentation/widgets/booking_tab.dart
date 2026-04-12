
import 'package:flutter/material.dart';
import 'package:urs_beauty/core/widgets/empty_state.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart';

class BookingTabContent extends StatelessWidget {
  const BookingTabContent({
    super.key,
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
            EmptyState(title: emptyTitle, subtitle: emptySubtitle),
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