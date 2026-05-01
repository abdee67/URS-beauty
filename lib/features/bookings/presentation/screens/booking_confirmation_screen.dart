import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/features/auth/domain/entities/customer_address_entity.dart';
import 'package:urs_beauty/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:urs_beauty/features/bookings/presentation/screens/booking_page.dart';
import 'package:urs_beauty/features/bookings/presentation/widgets/address_option_card_widget.dart';
import 'package:urs_beauty/core/widgets/error_state.dart';
import 'package:urs_beauty/features/bookings/presentation/widgets/empty_address_state_widget.dart';
import 'package:urs_beauty/features/bookings/presentation/widgets/selected_address_preview_widget.dart';
import 'package:urs_beauty/features/bookings/presentation/widgets/summary_card_widget.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';

class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({
    super.key,
    required this.serviceId,
    required this.serviceName,
    required this.stylist,
    required this.selectedDate,
    required this.selectedTime,
  });

  final String serviceId;
  final String serviceName;
  final Stylist stylist;
  final DateTime selectedDate;
  final String selectedTime;

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    Future.microtask(() {
      if (!mounted) {
        return;
      }

      context.read<BookingBloc>().add(
        LoadBookingContextEvent(widget.serviceId, widget.stylist.id),
      );
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final scheduledAt = _combineDateAndTime(
      widget.selectedDate,
      widget.selectedTime,
    );

    return BlocConsumer<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state.status == BookingBlocStatus.failure &&
            state.errorMessage.isNotEmpty) {
          final normalizedError = state.errorMessage.toLowerCase();
          if (normalizedError.contains('slot already booked')) {
            Navigator.of(context).pop(true);
            return;
          }

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage)));
        }

        if (state.status == BookingBlocStatus.addressCreated &&
            (state.message?.isNotEmpty ?? false)) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message!)));
        }

        if (state.status == BookingBlocStatus.created &&
            state.selectedBooking != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text(
                  'Booking created. Payment will be collected after the service is completed.',
                ),
              ),
            );

          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => const BookingPage(),
            ),
          );
        }
      },
      builder: (context, state) {
        if (_isInitialLoading(state)) {
          return _buildScaffold(
            context,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (_isInitialError(state)) {
          return _buildScaffold(
            context,
            child: ErrorState(message: state.errorMessage),
          );
        }

        final customer = state.customer!;
        final stylistService = state.stylistService!;
        final addresses = state.addresses;
        final selectedAddress = _findSelectedAddress(
          addresses,
          state.selectedAddressId,
        );
        final isSavingAddress = state.status == BookingBlocStatus.addressCreating;
        final isSubmitting = state.status == BookingBlocStatus.creating;

        return _buildScaffold(
          context,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroBanner(
                  serviceName: widget.serviceName,
                  stylistName: widget.stylist.businessName,
                  dateLabel: localizations.formatMediumDate(widget.selectedDate),
                  timeLabel: widget.selectedTime,
                ),
                const SizedBox(height: 18),
                SummaryCard(
                  serviceName: widget.serviceName,
                  stylistName: widget.stylist.businessName,
                  dateLabel: localizations.formatMediumDate(widget.selectedDate),
                  timeLabel: widget.selectedTime,
                  priceLabel: stylistService.price.toStringAsFixed(0),
                ),
                const SizedBox(height: 18),
                _SectionCard(
                  title: 'Service address',
                  subtitle:
                      'Choose where your stylist should arrive for this appointment.',
                  child: Column(
                    children: [
                      if (addresses.isEmpty)
                        AddressEmptyState(
                          isBusy: isSavingAddress,
                          onUseCurrentLocation: () {
                            context.read<BookingBloc>().add(
                              const UseCurrentLocationAddressEvent(),
                            );
                          },
                        )
                      else ...[
                        ...addresses.map(
                          (address) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AddressOptionCard(
                              address: address,
                              isSelected: address.id == state.selectedAddressId,
                              onTap: () {
                                context.read<BookingBloc>().add(
                                  SelectBookingAddressEvent(address.id),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: isSavingAddress
                                ? null
                                : () {
                                    context.read<BookingBloc>().add(
                                      const UseCurrentLocationAddressEvent(),
                                    );
                                  },
                            icon: isSavingAddress
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.my_location_rounded),
                            label: Text(
                              isSavingAddress
                                  ? 'Saving current location...'
                                  : 'Use current location as new address',
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF7A4A39),
                              side: const BorderSide(color: Color(0xFFD9B7A9)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (selectedAddress != null) ...[
                        const SizedBox(height: 16),
                        SelectedAddressPreview(address: selectedAddress),
                      ],
                      if (addresses.isNotEmpty && customer.defaultAddress == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: _MutedInfoText(
                            'Your selected address will be used for this booking.',
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _SectionCard(
                  title: 'Appointment notes',
                  subtitle:
                      'Add any helpful details for the stylist before arrival.',
                  child: TextField(
                    controller: _notesController,
                    minLines: 4,
                    maxLines: 5,
                    decoration: _inputDecoration(
                      hintText:
                          'Gate code, landmark, parking info, or anything else they should know.',
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () {
                            context.read<BookingBloc>().add(
                              ConfirmBookingEvent(
                                serviceId: widget.serviceId,
                                stylistId: widget.stylist.id,
                                scheduledAt: scheduledAt,
                                notes: _notesController.text.trim(),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B3F32),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      isSubmitting
                          ? 'Creating booking...'
                          : 'Confirm booking',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Scaffold _buildScaffold(BuildContext context, {required Widget child}) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Confirm booking',
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
        child: SafeArea(child: child),
      ),
    );
  }

  bool _isInitialLoading(BookingState state) {
    return state.status == BookingBlocStatus.loading ||
        (state.customer == null &&
            state.status != BookingBlocStatus.failure &&
            state.stylistService == null);
  }

  bool _isInitialError(BookingState state) {
    return state.status == BookingBlocStatus.failure &&
        state.customer == null &&
        state.stylistService == null;
  }

  CustomerAddressEntity? _findSelectedAddress(
    List<CustomerAddressEntity> addresses,
    String? selectedAddressId,
  ) {
    if ((selectedAddressId ?? '').trim().isEmpty) {
      return null;
    }

    for (final address in addresses) {
      if (address.id == selectedAddressId) {
        return address;
      }
    }

    return null;
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
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s?(AM|PM)$').firstMatch(
      normalized,
    );

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

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: const Color(0xFFFFFAF5),
      contentPadding: const EdgeInsets.all(18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFF1D8CB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFB67C65)),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.serviceName,
    required this.stylistName,
    required this.dateLabel,
    required this.timeLabel,
  });

  final String serviceName;
  final String stylistName;
  final String dateLabel;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7A4A39), Color(0xFFA7684F)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Almost there',
            style: TextStyle(
              color: Color(0xFFFFE9DC),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            serviceName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'with $stylistName',
            style: const TextStyle(
              color: Color(0xFFFFE9DC),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(icon: Icons.calendar_today_outlined, label: dateLabel),
              _InfoChip(icon: Icons.access_time_rounded, label: timeLabel),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0D7CB)),
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
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF7B6156),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MutedInfoText extends StatelessWidget {
  const _MutedInfoText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: const Color(0xFF7B6156),
      ),
    );
  }
}
