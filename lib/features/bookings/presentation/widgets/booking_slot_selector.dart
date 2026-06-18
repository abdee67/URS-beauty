import 'package:flutter/material.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_availability_slot_entity.dart';

class BookingSlotSelector extends StatelessWidget {
  const BookingSlotSelector({
    super.key,
    required this.availableDates,
    required this.selectedDate,
    required this.selectedTime,
    required this.slots,
    required this.isLoading,
    required this.onDateSelected,
    required this.onSlotSelected,
    this.dateTitle = 'Choose a date',
    this.slotsTitle = 'Available time slots',
  });

  final List<DateTime> availableDates;
  final DateTime selectedDate;
  final String selectedTime;
  final List<StylistAvailabilitySlotEntity> slots;
  final bool isLoading;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<StylistAvailabilitySlotEntity> onSlotSelected;
  final String dateTitle;
  final String slotsTitle;

  @override
  Widget build(BuildContext context) {
    final hasAvailableSlots = slots.any((slot) => slot.isAvailable);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF43261D),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: availableDates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final date = availableDates[index];
              return _DateCard(
                date: date,
                isSelected: _isSameDate(date, selectedDate),
                onTap: () => onDateSelected(date),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text(
                slotsTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF43261D),
                ),
              ),
            ),
            if (!isLoading && slots.isNotEmpty)
              _AvailabilityPill(
                label: hasAvailableSlots
                    ? '${slots.where((slot) => slot.isAvailable).length} open'
                    : 'Fully booked',
              ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _SlotsSection(
            isLoading: isLoading,
            slots: slots,
            selectedTime: selectedTime,
            onSelect: onSlotSelected,
          ),
        ),
      ],
    );
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}

class _DateCard extends StatelessWidget {
  const _DateCard({
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    return Material(
      color: isSelected ? const Color(0xFFC96A3D) : Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          width: 84,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _weekdayLabel(date),
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF7C5342),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${date.day}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFF43261D),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                localizations.formatMonthYear(date).split(' ').first,
                style: TextStyle(
                  color: isSelected ? Colors.white70 : const Color(0xFF7C5342),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _weekdayLabel(DateTime value) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[value.weekday - 1];
  }
}

class _SlotsSection extends StatelessWidget {
  const _SlotsSection({
    required this.isLoading,
    required this.slots,
    required this.selectedTime,
    required this.onSelect,
  });

  final bool isLoading;
  final List<StylistAvailabilitySlotEntity> slots;
  final String selectedTime;
  final ValueChanged<StylistAvailabilitySlotEntity> onSelect;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SingleChildScrollView(child: _SlotLoadingView());
    }

    if (slots.isEmpty) {
      return const _NoSlotsView(
        title: 'No availability for this day',
        subtitle: 'Try another day to see working hours and open times.',
      );
    }

    final hasAvailableSlots = slots.any((slot) => slot.isAvailable);
    final crossAxisCount = MediaQuery.of(context).size.width > 420 ? 3 : 2;
    final localizations = MaterialLocalizations.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!hasAvailableSlots)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: _InlineInfoCard(
                title: 'No availability for this day',
                subtitle:
                    'All working slots are currently taken. Please choose another time.',
              ),
            ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: slots.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.45,
            ),
            itemBuilder: (context, index) {
              final slot = slots[index];
              final label = localizations.formatTimeOfDay(
                TimeOfDay.fromDateTime(slot.startAt),
              );
              final isSelected = slot.isAvailable && selectedTime == label;
              return _TimeSlotCard(
                label: label,
                isAvailable: slot.isAvailable,
                isSelected: isSelected,
                onTap: slot.isAvailable ? () => onSelect(slot) : null,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TimeSlotCard extends StatelessWidget {
  const _TimeSlotCard({
    required this.label,
    required this.isAvailable,
    required this.isSelected,
    this.onTap,
  });

  final String label;
  final bool isAvailable;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? const Color(0xFFC96A3D)
        : isAvailable
        ? Colors.white
        : const Color(0xFFF3E3D9);
    final borderColor = isSelected
        ? const Color(0xFFC96A3D)
        : isAvailable
        ? const Color(0xFFE8D4C6)
        : const Color(0xFFEAD3C7);
    final textColor = isSelected
        ? Colors.white
        : isAvailable
        ? const Color(0xFF43261D)
        : const Color(0xFFB08B7B);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x26C96A3D),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                isAvailable ? Icons.access_time_rounded : Icons.block_rounded,
                color: isSelected ? Colors.white : textColor,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isAvailable ? 'Available' : 'Unavailable',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected ? Colors.white70 : textColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvailabilityPill extends StatelessWidget {
  const _AvailabilityPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(220),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE7D2C6)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF7C5342),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SlotLoadingView extends StatelessWidget {
  const _SlotLoadingView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(
        6,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 74,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(170),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineInfoCard extends StatelessWidget {
  const _InlineInfoCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(220),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEED8CC)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.event_busy_rounded, color: Color(0xFF9F6B57)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF43261D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF7C5342),
                    height: 1.35,
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

class _NoSlotsView extends StatelessWidget {
  const _NoSlotsView({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFF6E4D7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                color: Color(0xFF9A6C5A),
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF43261D),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF7C5342),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
