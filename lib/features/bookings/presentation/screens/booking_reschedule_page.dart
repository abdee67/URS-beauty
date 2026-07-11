import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/core/widgets/header.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart';
import 'package:urs_beauty/features/bookings/domain/entities/reschedule_booking_request.dart';
import 'package:urs_beauty/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:urs_beauty/features/bookings/presentation/widgets/booking_slot_selector.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';
import 'package:urs_beauty/features/stylists/presentation/bloc/bloc/stylists_bloc.dart';
import 'package:urs_beauty/features/stylists/presentation/widgets/stylist_avatar.dart';

class BookingReschedulePage extends StatefulWidget {
  const BookingReschedulePage({super.key, required this.booking});

  final BookingEntity booking;

  @override
  State<BookingReschedulePage> createState() => _BookingReschedulePageState();
}

class _BookingReschedulePageState extends State<BookingReschedulePage> {
  late final List<DateTime> _availableDates;
  String? _serviceId;
  Stylist? _selectedStylist;
  bool _didRequestStylists = false;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _availableDates = List<DateTime>.generate(
      14,
      (index) => DateTime(today.year, today.month, today.day + index),
    );

    Future.microtask(() {
      if (!mounted) {
        return;
      }

      final bookingBloc = context.read<BookingBloc>();
      bookingBloc.add(StartRescheduleFlowEvent(widget.booking));
      bookingBloc.add(SelectDateEvent(_availableDates.first));
      bookingBloc.add(const SelectTimeEvent(''));
      bookingBloc.add(GetBookingServicesEvent(widget.booking.id));
    });
  }

  bool get _hasReachedLimit => widget.booking.rescheduledCount >= 2;

  bool get _isPendingLocked {
    if (widget.booking.status != BookingStatus.pending) {
      return false;
    }

    return widget.booking.scheduledAt.isBefore(
      DateTime.now().add(const Duration(hours: 5)),
    );
  }

  bool get _isRescheduleLocked => _hasReachedLimit || _isPendingLocked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<BookingBloc, BookingState>(
          listener: _handleBookingStateChange,
        ),
        BlocListener<StylistsBloc, StylistsState>(
          listener: _handleStylistsStateChange,
        ),
      ],
      child: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, bookingState) {
          return BlocBuilder<StylistsBloc, StylistsState>(
            builder: (context, stylistsState) {
              final selectedDate =
                  bookingState.selectedDate ?? _availableDates.first;
              final slots = stylistsState.stylistsAvailabilityByTime;
              final selectedSlotIsAvailable = slots.any(
                (slot) =>
                    slot.isAvailable &&
                    _slotLabel(context, slot.startAt) ==
                        bookingState.selectedTime,
              );
              final isSubmitting =
                  bookingState.status == BookingBlocStatus.rescheduling;
              final isLoadingServices =
                  bookingState.status == BookingBlocStatus.servicesLoading &&
                  bookingState.bookingServices.isEmpty;
              final isLoadingStylists =
                  stylistsState.status ==
                      StylistsStatus.stylistsByServiceLoading &&
                  stylistsState.stylistsByService.isEmpty;
              final isLoadingSlots =
                  stylistsState.status ==
                  StylistsStatus.stylistsAvailabilityByTimeLoading;
              final selectedComparison = _buildSelectedComparison(
                context,
                selectedDate: selectedDate,
                selectedTime: bookingState.selectedTime,
                selectedStylist: _selectedStylist,
              );

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
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Header(
                              theme: theme,
                              title: 'Move your appointment',
                              description:
                                  'Keep the same service, choose a new stylist and time, and we will create a fresh booking record.',
                            ),
                            const SizedBox(height: 16),
                            _CurrentBookingPreview(
                              booking: widget.booking,
                              remainingReschedules:
                                  2 - widget.booking.rescheduledCount,
                            ),
                            const SizedBox(height: 14),
                            if (_isRescheduleLocked)
                              _InfoCard(
                                title: 'Reschedule unavailable',
                                subtitle: _hasReachedLimit
                                    ? 'This booking already reached the maximum of 2 reschedules.'
                                    : 'Pending bookings can only be rescheduled at least 5 hours before the appointment.',
                              )
                            else ...[
                              _OldToNewCard(
                                oldLabel: _formatOldBooking(context),
                                newLabel: selectedComparison,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Choose a stylist',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF43261D),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 108,
                                child: isLoadingServices || isLoadingStylists
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : _buildStylistSelector(stylistsState),
                              ),
                              const SizedBox(height: 14),
                              if (_selectedStylist == null ||
                                  _serviceId == null)
                                const _InfoCard(
                                  title: 'Stylist selection required',
                                  subtitle:
                                      'We could not prepare rescheduling yet. Please try again after the booking services finish loading.',
                                )
                              else
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 400,
                                      child: BookingSlotSelector(
                                        availableDates: _availableDates,
                                        selectedDate: selectedDate,
                                        selectedTime: bookingState.selectedTime,
                                        slots: slots,
                                        isLoading: isLoadingSlots,
                                        onDateSelected: (date) {
                                          context.read<BookingBloc>().add(
                                            SelectDateEvent(date),
                                          );
                                          context.read<BookingBloc>().add(
                                            const SelectTimeEvent(''),
                                          );
                                          _loadSlotsFor(date);
                                        },
                                        onSlotSelected: (slot) {
                                          context.read<BookingBloc>().add(
                                            SelectTimeEvent(
                                              _slotLabel(context, slot.startAt),
                                            ),
                                          );
                                        },
                                        dateTitle: 'Choose a new date',
                                        slotsTitle: 'Choose a new time',
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed:
                                            isSubmitting ||
                                                !selectedSlotIsAvailable
                                            ? null
                                            : () {
                                                context.read<BookingBloc>().add(
                                                  RescheduleBookingEvent(
                                                    RescheduleBookingRequestEntity(
                                                      bookingId:
                                                          widget.booking.id,
                                                      stylistId:
                                                          _selectedStylist!.id,
                                                      scheduledAt:
                                                          _combineDateAndTime(
                                                            selectedDate,
                                                            bookingState
                                                                .selectedTime,
                                                          ),
                                                    ),
                                                  ),
                                                );
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF6B3F32,
                                          ),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          isSubmitting
                                              ? 'Confirming...'
                                              : 'Confirm Reschedule',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _handleBookingStateChange(BuildContext context, BookingState state) {
    if (!_didRequestStylists && state.bookingServices.isNotEmpty) {
      _didRequestStylists = true;
      _serviceId = state.bookingServices.first.serviceId;
      context.read<StylistsBloc>().add(GetStylistsByServiceEvent(_serviceId!));
    }

    if (state.status == BookingBlocStatus.failure &&
        state.errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.errorMessage)));

      if (_selectedStylist != null && _serviceId != null) {
        _loadSlotsFor(state.selectedDate ?? _availableDates.first);
      }
    }

    if (state.status == BookingBlocStatus.rescheduled &&
        state.selectedBooking != null) {
      Navigator.of(context).pop(true);
    }
  }

  void _handleStylistsStateChange(BuildContext context, StylistsState state) {
    if (state.errorMessage.isNotEmpty &&
        (state.status == StylistsStatus.stylistsError ||
            state.status == StylistsStatus.stylistsAvailabilityError)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.errorMessage)));
      return;
    }

    if (state.status == StylistsStatus.stylistsByServiceLoaded) {
      final stylists = state.stylistsByService;
      if (stylists.isEmpty) {
        setState(() {
          _selectedStylist = null;
        });
        return;
      }

      final hasCurrentSelection =
          _selectedStylist != null &&
          stylists.any((stylist) => stylist.id == _selectedStylist!.id);
      if (hasCurrentSelection) {
        return;
      }

      final selectedStylist = stylists.where(
        (stylist) => stylist.id == widget.booking.stylistId,
      );
      final nextStylist = selectedStylist.isNotEmpty
          ? selectedStylist.first
          : stylists.first;

      setState(() {
        _selectedStylist = nextStylist;
      });

      context.read<BookingBloc>().add(const SelectTimeEvent(''));
      _loadSlotsFor(
        context.read<BookingBloc>().state.selectedDate ?? _availableDates.first,
      );
    }

    if (state.status == StylistsStatus.stylistsAvailabilityByTimeError &&
        state.errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.errorMessage)));
    }
  }

  Widget _buildStylistSelector(StylistsState stylistsState) {
    final stylists = stylistsState.stylistsByService;
    if (stylists.isEmpty) {
      return const _InfoCard(
        title: 'No stylists available',
        subtitle:
            'We could not find any stylist who currently offers this service.',
      );
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: stylists.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        final stylist = stylists[index];
        final isSelected = stylist.id == _selectedStylist?.id;
        final isCurrent = stylist.id == widget.booking.stylistId;

        return _StylistOptionCard(
          stylist: stylist,
          isSelected: isSelected,
          isCurrent: isCurrent,
          onTap: () {
            setState(() {
              _selectedStylist = stylist;
            });
            context.read<BookingBloc>().add(const SelectTimeEvent(''));
            _loadSlotsFor(
              context.read<BookingBloc>().state.selectedDate ??
                  _availableDates.first,
            );
          },
        );
      },
    );
  }

  void _loadSlotsFor(DateTime date) {
    final stylist = _selectedStylist;
    final serviceId = _serviceId;
    if (stylist == null || serviceId == null) {
      return;
    }

    final stylistId = stylist.id.trim();
    final trimmedServiceId = serviceId.trim();
    if (stylistId.isEmpty || trimmedServiceId.isEmpty) {
      return;
    }

    context.read<StylistsBloc>().add(
      GetStylistsAvailabilityByTimeEvent(
        stylistId,
        trimmedServiceId,
        date,
        ignoredBookingId: widget.booking.id,
      ),
    );
  }

  String _slotLabel(BuildContext context, DateTime dateTime) {
    return MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(dateTime));
  }

  String _formatOldBooking(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    return '${widget.booking.stylistName} on '
        '${localizations.formatMediumDate(widget.booking.scheduledAt)} at '
        '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(widget.booking.scheduledAt))}';
  }

  String _buildSelectedComparison(
    BuildContext context, {
    required DateTime selectedDate,
    required String selectedTime,
    required Stylist? selectedStylist,
  }) {
    if (selectedStylist == null || selectedTime.isEmpty) {
      return 'Pick a stylist, date, and time to preview the new appointment.';
    }

    final localizations = MaterialLocalizations.of(context);
    return '${selectedStylist.businessName} on '
        '${localizations.formatMediumDate(selectedDate)} at $selectedTime';
  }

  DateTime _combineDateAndTime(DateTime date, String timeLabel) {
    final parsedTime = _parseTimeLabel(timeLabel);
    return DateTime(
      date.year,
      date.month,
      date.day,
      parsedTime.hour,
      parsedTime.minute,
    );
  }

  TimeOfDay _parseTimeLabel(String value) {
    final normalized = value.trim().toUpperCase();
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s?(AM|PM)$',
    ).firstMatch(normalized);

    if (match == null) {
      throw FormatException('Invalid time slot: $value');
    }

    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final period = match.group(3)!;

    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }
}

// Rest of the helper widgets remain unchanged

class _CurrentBookingPreview extends StatelessWidget {
  const _CurrentBookingPreview({
    required this.booking,
    required this.remainingReschedules,
  });

  final BookingEntity booking;
  final int remainingReschedules;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final dateLabel = localizations.formatMediumDate(booking.scheduledAt);
    final timeLabel = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(booking.scheduledAt),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0D8CA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.serviceName.isEmpty
                      ? 'Beauty service'
                      : booking.serviceName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF43261D),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7E7DA),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$remainingReschedules left',
                  style: const TextStyle(
                    color: Color(0xFF7B6156),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            booking.stylistName,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF7B6156)),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetaChip(icon: Icons.calendar_today_outlined, label: dateLabel),
              _MetaChip(icon: Icons.access_time_rounded, label: timeLabel),
              _MetaChip(
                icon: Icons.history_toggle_off_rounded,
                label: 'Rescheduled ${booking.rescheduledCount} times',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OldToNewCard extends StatelessWidget {
  const _OldToNewCard({required this.oldLabel, required this.newLabel});

  final String oldLabel;
  final String newLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF0D7CB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Old -> New',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF43261D),
            ),
          ),
          const SizedBox(height: 14),
          _ComparisonRow(label: 'Current', value: oldLabel),
          const SizedBox(height: 10),
          _ComparisonRow(label: 'New', value: newLabel),
        ],
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF7B6156),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF43261D),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _StylistOptionCard extends StatelessWidget {
  const _StylistOptionCard({
    required this.stylist,
    required this.isSelected,
    required this.isCurrent,
    required this.onTap,
  });

  final Stylist stylist;
  final bool isSelected;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xFF6B3F32) : Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          width: 196,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF6B3F32)
                  : const Color(0xFFEAD3C7),
            ),
          ),
          child: Row(
            children: [
              StylistAvatar(imageUrl: stylist.imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      stylist.businessName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF43261D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isCurrent ? 'Current stylist' : 'Tap to reschedule here',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? const Color(0xFFFFDFC9)
                            : const Color(0xFF7B6156),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8EEE6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF9E735F)),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF7B6156),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF0D8CA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF43261D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
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
