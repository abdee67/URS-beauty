import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/core/constants/app_colors.dart';
import 'package:urs_beauty/core/widgets/error_state.dart';
import 'package:urs_beauty/features/auth/domain/entities/customer_address_entity.dart';
import 'package:urs_beauty/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:urs_beauty/features/bookings/presentation/screens/booking_page.dart';
import 'package:urs_beauty/features/bookings/presentation/widgets/address_option_card_widget.dart';
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
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: AppColors.error,
              ),
            );
        }

        if (state.status == BookingBlocStatus.addressCreated &&
            (state.message?.isNotEmpty ?? false)) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: AppColors.clay,
              ),
            );
        }

        if (state.status == BookingBlocStatus.created &&
            state.selectedBooking != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text(
                  'Booking created successfully! Payment will be collected after completion.',
                ),
                backgroundColor: AppColors.sage,
              ),
            );

          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => const BookingPage()),
          );
        }
      },
      builder: (context, state) {
        if (_isInitialLoading(state)) {
          return _buildScaffold(
            context,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.clay),
            ),
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
        final isSavingAddress =
            state.status == BookingBlocStatus.addressCreating;
        final isSubmitting = state.status == BookingBlocStatus.creating;

        return _buildScaffold(
          context,
          bottomNavigationBar: _buildBottomBar(
            context,
            priceLabel: stylistService.price.toStringAsFixed(0),
            isSubmitting: isSubmitting,
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
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroBanner(
                  serviceName: widget.serviceName,
                  stylistName: widget.stylist.businessName,
                  dateLabel: localizations.formatMediumDate(
                    widget.selectedDate,
                  ),
                  timeLabel: widget.selectedTime,
                ),
                const SizedBox(height: 20),
                SummaryCard(
                  serviceName: widget.serviceName,
                  stylistName: widget.stylist.businessName,
                  dateLabel: localizations.formatMediumDate(
                    widget.selectedDate,
                  ),
                  timeLabel: widget.selectedTime,
                  priceLabel: stylistService.price.toStringAsFixed(0),
                ),
                const SizedBox(height: 20),
                _SectionCard(
                  icon: Icons.location_on_rounded,
                  title: 'Service location',
                  subtitle:
                      'Select where your stylist will perform the appointment.',
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
                          (address) => AddressOptionCard(
                            address: address,
                            isSelected: address.id == state.selectedAddressId,
                            onTap: () {
                              context.read<BookingBloc>().add(
                                SelectBookingAddressEvent(address.id),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 4),
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
                                      color: AppColors.clay,
                                    ),
                                  )
                                : const Icon(
                                    Icons.my_location_rounded,
                                    size: 18,
                                  ),
                            label: Text(
                              isSavingAddress
                                  ? 'Saving location...'
                                  : 'Use current location as new address',
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.clay,
                              backgroundColor: AppColors.field.withValues(
                                alpha: 0.5,
                              ),
                              side: const BorderSide(color: AppColors.border),
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
                      if (addresses.isNotEmpty &&
                          customer.defaultAddress == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: _MutedInfoText(
                            'Your selected address will be used for this booking.',
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SectionCard(
                  icon: Icons.edit_note_rounded,
                  title: 'Appointment notes',
                  subtitle:
                      'Provide gate codes, landmarks, or special instructions.',
                  child: TextField(
                    controller: _notesController,
                    minLines: 3,
                    maxLines: 5,
                    style: const TextStyle(color: AppColors.ink, fontSize: 14),
                    decoration: _inputDecoration(
                      hintText:
                          'e.g. Apartment #3B, gate code 4920, park in guest slot...',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Scaffold _buildScaffold(
    BuildContext context, {
    required Widget child,
    Widget? bottomNavigationBar,
  }) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.clay.withValues(alpha: 0.5),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: 20),
              color: AppColors.ink,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirm Booking',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Step 2 of 2',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.successSurface),
            ),
          ],
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.paper, AppColors.field],
          ),
        ),
        child: SafeArea(child: child),
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context, {
    required String priceLabel,
    required bool isSubmitting,
    required VoidCallback? onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.8)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Estimated',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ETB $priceLabel',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.clay,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.clay,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.rose,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isSubmitting
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Creating...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Confirm Booking',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
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

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
      filled: true,
      fillColor: AppColors.field,
      contentPadding: const EdgeInsets.all(16),
      prefixIcon: const Icon(
        Icons.edit_note_rounded,
        color: AppColors.clay,
        size: 22,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.clay, width: 1.8),
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.clay, Color(0xFF834C3C)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.clay.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'READY TO BOOK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Text(
                  stylistName.isNotEmpty ? stylistName[0].toUpperCase() : 'S',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            serviceName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                size: 16,
                color: AppColors.peach,
              ),
              const SizedBox(width: 6),
              Text(
                'with $stylistName',
                style: const TextStyle(
                  color: AppColors.peach,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(icon: Icons.calendar_today_rounded, label: dateLabel),
              _InfoChip(
                icon: Icons.access_time_filled_rounded,
                label: timeLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.clay.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.field,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.clay, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
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
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
    );
  }
}
