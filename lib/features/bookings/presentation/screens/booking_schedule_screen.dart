import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/core/widgets/header.dart';
import 'package:urs_beauty/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:urs_beauty/features/bookings/presentation/screens/booking_confirmation_screen.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_availability_slot_entity.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';
import 'package:urs_beauty/features/stylists/presentation/bloc/bloc/stylists_bloc.dart';

class BookingScheduleScreen extends StatefulWidget {
  const BookingScheduleScreen({
    super.key,
    required this.serviceId,
    required this.serviceName,
    required this.stylist,
  });

  final String serviceId;
  final String serviceName;
  final Stylist stylist;

  @override
  State<BookingScheduleScreen> createState() => _BookingScheduleScreenState();
}

class _BookingScheduleScreenState extends State<BookingScheduleScreen> {
  late final List<DateTime> _availableDates;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _availableDates = List<DateTime>.generate(
      7,
      (index) => DateTime(today.year, today.month, today.day + index),
    );

    final initialDate =
        context.read<BookingBloc>().state.selectedDate ?? _availableDates.first;
    context.read<BookingBloc>().add(SelectDateEvent(initialDate));
    context.read<BookingBloc>().add(const SelectTimeEvent(''));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _loadSlotsForDate(initialDate);
    });
  }

  void _loadSlotsForDate(DateTime date) {
    context.read<StylistsBloc>().add(
      GetStylistsAvailabilityByTimeEvent(
        widget.stylist.id,
        widget.serviceId,
        date,
      ),
    );
  }

  Future<void> _openConfirmation(
    DateTime selectedDate,
    String selectedTime,
  ) async {
    final navigator = Navigator.of(context);
    final result = await navigator.push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => BlocProvider.value(
          value: context.read<BookingBloc>(),
          child: BookingConfirmationScreen(
            serviceId: widget.serviceId,
            serviceName: widget.serviceName,
            stylist: widget.stylist,
            selectedDate: selectedDate,
            selectedTime: selectedTime,
          ),
        ),
      ),
    );

    if (!mounted || result != true) {
      return;
    }

    context.read<BookingBloc>().add(const SelectTimeEvent(''));
    _loadSlotsForDate(selectedDate);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'That slot is no longer available. Please pick another time.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<StylistsBloc, StylistsState>(
      listener: (context, stylistsState) {
        if (stylistsState.status == StylistsStatus.stylistsError &&
            stylistsState.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(stylistsState.errorMessage)));
        }
      },
      builder: (context, stylistsState) {
        return BlocBuilder<BookingBloc, BookingState>(
          builder: (context, bookingState) {
            final selectedDate =
                bookingState.selectedDate ?? _availableDates.first;
            final slots = stylistsState.stylistsAvailabilityByTime;
            final hasAvailableSlots = slots.any((slot) => slot.isAvailable);
            final selectedSlotIsAvailable = slots.any(
              (slot) =>
                  slot.isAvailable &&
                  _slotLabel(context, slot.startAt) ==
                      bookingState.selectedTime,
            );
            final isLoading =
                stylistsState.status ==
                StylistsStatus.stylistsAvailabilityByTimeLoading;

            return Scaffold(
              backgroundColor: const Color(0xFFFFFBF6),
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFF4EA), Color(0xFFFFE0C7)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Header(
                          theme: theme,
                          title: 'Book ${widget.serviceName}',
                          description: 'with ${widget.stylist.businessName}',
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Choose a date',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF43261D),
                              ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 92,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _availableDates.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final date = _availableDates[index];
                              final isSelected = _isSameDate(
                                date,
                                selectedDate,
                              );
                              return _DateCard(
                                date: date,
                                isSelected: isSelected,
                                onTap: () {
                                  context.read<BookingBloc>().add(
                                    SelectDateEvent(date),
                                  );
                                  context.read<BookingBloc>().add(
                                    const SelectTimeEvent(''),
                                  );
                                  _loadSlotsForDate(date);
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Available time slots',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
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
                            selectedTime: bookingState.selectedTime,
                            onSelect: (slot) {
                              context.read<BookingBloc>().add(
                                SelectTimeEvent(
                                  _slotLabel(context, slot.startAt),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                bookingState.selectedTime.isEmpty ||
                                    !selectedSlotIsAvailable
                                ? null
                                : () => _openConfirmation(
                                    selectedDate,
                                    bookingState.selectedTime,
                                  ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B3F32),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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
      },
    );
  }

  String _slotLabel(BuildContext context, DateTime dateTime) {
    final localizations = MaterialLocalizations.of(context);
    return localizations.formatTimeOfDay(TimeOfDay.fromDateTime(dateTime));
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}

class _BookingHeader extends StatelessWidget {
  const _BookingHeader({required this.serviceName, required this.stylistName});

  final String serviceName;
  final String stylistName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(220),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            serviceName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF43261D),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Booking with $stylistName',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF7C5342)),
          ),
        ],
      ),
    );
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
