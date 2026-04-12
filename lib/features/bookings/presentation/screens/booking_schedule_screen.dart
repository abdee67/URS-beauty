import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:urs_beauty/features/bookings/presentation/screens/booking_confirmation_screen.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';

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
    _availableDates = List<DateTime>.generate(7, (index) {
      final now = DateTime.now();
      final date = DateTime(now.year, now.month, now.day + index);
      return date;
    });

    final bloc = context.read<BookingBloc>();
    if (bloc.state.selectedDate == null) {
      bloc.add(SelectDateEvent(_availableDates.first));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        final selectedDate = state.selectedDate ?? _availableDates.first;
        final timeSlots = _timeSlotsForDate(selectedDate);

        return Scaffold(
          backgroundColor: const Color(0xFFFFFBF6),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Select date & time',
              style: TextStyle(color: Color(0xFF5C2E1F)),
            ),
          ),
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
                    _BookingHeader(
                      serviceName: widget.serviceName,
                      stylistName: widget.stylist.businessName,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Choose a date',
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
                        itemCount: _availableDates.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final date = _availableDates[index];
                          final isSelected = _isSameDate(date, selectedDate);
                          return _DateCard(
                            date: date,
                            isSelected: isSelected,
                            onTap: () {
                              final bloc = context.read<BookingBloc>();
                              bloc.add(SelectDateEvent(date));
                              bloc.add(const SelectTimeEvent(''));
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Available time slots',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF43261D),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: timeSlots.isEmpty
                          ? const _NoSlotsView()
                          : SingleChildScrollView(
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: timeSlots.map((slot) {
                                  final label = _slotLabel(context, slot);
                                  final isSelected =
                                      state.selectedTime == label;
                                  return _TimeChip(
                                    label: label,
                                    isSelected: isSelected,
                                    onTap: () {
                                      context.read<BookingBloc>().add(
                                        SelectTimeEvent(label),
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.selectedTime.isEmpty
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<BookingBloc>(),
                                      child: BookingConfirmationScreen(
                                        serviceId: widget.serviceId,
                                        serviceName: widget.serviceName,
                                        stylist: widget.stylist,
                                        selectedDate: selectedDate,
                                        selectedTime: state.selectedTime,
                                      ),
                                    ),
                                  ),
                                );
                              },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text('Continue'),
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
  }

  List<TimeOfDay> _timeSlotsForDate(DateTime date) {
    final slots = <TimeOfDay>[];
    final now = DateTime.now();
    final isToday = _isSameDate(date, now);

    for (var hour = 9; hour <= 18; hour++) {
      for (final minute in const [0, 30]) {
        if (hour == 18 && minute > 0) {
          continue;
        }

        final slot = TimeOfDay(hour: hour, minute: minute);
        final slotDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          slot.hour,
          slot.minute,
        );

        if (isToday &&
            slotDateTime.isBefore(now.add(const Duration(minutes: 30)))) {
          continue;
        }

        slots.add(slot);
      }
    }

    return slots;
  }

  String _slotLabel(BuildContext context, TimeOfDay slot) {
    return slot.format(context);
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

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Text(label),
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFFC96A3D),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF43261D),
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }
}

class _NoSlotsView extends StatelessWidget {
  const _NoSlotsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No time slots left for this day.',
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF7C5342)),
      ),
    );
  }
}
