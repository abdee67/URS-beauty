import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/core/widgets/header.dart';
import 'package:urs_beauty/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:urs_beauty/features/bookings/presentation/screens/booking_confirmation_screen.dart';
import 'package:urs_beauty/features/bookings/presentation/widgets/booking_slot_selector.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';
import 'package:urs_beauty/features/stylists/presentation/bloc/bloc/stylists_bloc.dart';

class BookingScheduleScreen extends StatefulWidget {
  const BookingScheduleScreen({
    super.key,
    required this.serviceId,
    required this.serviceName,
    required this.stylist,
    this.initialDateTime,
  });

  final String serviceId;
  final String serviceName;
  final Stylist stylist;
  final DateTime? initialDateTime;

  @override
  State<BookingScheduleScreen> createState() => _BookingScheduleScreenState();
}

class _BookingScheduleScreenState extends State<BookingScheduleScreen> {
  late final List<DateTime> _availableDates;
  bool _didInitializeSelection = false;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _availableDates = List<DateTime>.generate(
      14,
      (index) => DateTime(today.year, today.month, today.day + index),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitializeSelection) {
      return;
    }
    _didInitializeSelection = true;

    final initialDate = _initialDate();
    final initialTimeLabel = widget.initialDateTime == null
        ? ''
        : MaterialLocalizations.of(
            context,
          ).formatTimeOfDay(TimeOfDay.fromDateTime(widget.initialDateTime!));
    context.read<BookingBloc>().add(SelectDateEvent(initialDate));
    context.read<BookingBloc>().add(SelectTimeEvent(initialTimeLabel));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _loadSlotsForDate(initialDate);
    });
  }

  DateTime _initialDate() {
    final requested = widget.initialDateTime;
    if (requested == null) {
      return context.read<BookingBloc>().state.selectedDate ??
          _availableDates.first;
    }

    final requestedDate = DateTime(
      requested.year,
      requested.month,
      requested.day,
    );
    final firstDate = _availableDates.first;
    if (requestedDate.isBefore(firstDate)) {
      return firstDate;
    }
    return requestedDate;
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
    final result = await Navigator.of(context).push<bool>(
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
                        Expanded(
                          child: BookingSlotSelector(
                            availableDates: _availableDates,
                            selectedDate: selectedDate,
                            selectedTime: bookingState.selectedTime,
                            slots: slots,
                            isLoading: isLoading,
                            onDateSelected: (date) {
                              context.read<BookingBloc>().add(
                                SelectDateEvent(date),
                              );
                              context.read<BookingBloc>().add(
                                const SelectTimeEvent(''),
                              );
                              _loadSlotsForDate(date);
                            },
                            onSlotSelected: (slot) {
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
    return MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(dateTime));
  }
}
