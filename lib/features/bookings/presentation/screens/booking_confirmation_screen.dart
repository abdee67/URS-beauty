import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/config/supabase_config.dart';
import 'package:urs_beauty/features/auth/domain/usecases/get_current_client.dart';
import 'package:urs_beauty/features/bookings/data/models/create_booking_request_model.dart';
import 'package:urs_beauty/features/bookings/data/models/create_booking_service_item_model.dart';
import 'package:urs_beauty/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:urs_beauty/features/bookings/presentation/screens/booking_success_screen.dart';
import 'package:urs_beauty/features/stylists/data/models/stylists_service_model.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';
import 'package:urs_beauty/features/stylists/domain/repository/stylists_repository.dart';
import 'package:urs_beauty/injection_container.dart';

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
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;
  late final Future<_BookingPayloadContext> _payloadContextFuture;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController();
    _notesController = TextEditingController();
    _payloadContextFuture = _loadPayloadContext();
  }

  @override
  void dispose() {
    _addressController.dispose();
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
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage)));
        }

        if (state.status == BookingBlocStatus.created &&
            state.selectedBooking != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => BookingSuccessScreen(
                booking: state.selectedBooking!,
                serviceName: widget.serviceName,
                stylistName: widget.stylist.businessName,
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state.status == BookingBlocStatus.creating;

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
            child: SafeArea(
              child: FutureBuilder<_BookingPayloadContext>(
                future: _payloadContextFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return _BookingErrorState(
                      message: snapshot.error.toString(),
                    );
                  }

                  final payloadContext = snapshot.data;
                  if (payloadContext == null) {
                    return const _BookingErrorState(
                      message: 'Unable to prepare booking details.',
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SummaryCard(
                          serviceName: widget.serviceName,
                          stylistName: widget.stylist.businessName,
                          dateLabel: localizations.formatMediumDate(
                            widget.selectedDate,
                          ),
                          timeLabel: widget.selectedTime,
                          priceLabel: payloadContext.stylistService.price
                              .toStringAsFixed(0),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Address',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF43261D),
                              ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _addressController,
                          minLines: 2,
                          maxLines: 3,
                          decoration: _inputDecoration(
                            hintText: 'Where should the stylist come?',
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Notes',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF43261D),
                              ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _notesController,
                          minLines: 3,
                          maxLines: 4,
                          decoration: _inputDecoration(
                            hintText:
                                'Anything the stylist should know before arriving?',
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () => _submitBooking(
                                    context,
                                    payloadContext,
                                    scheduledAt,
                                  ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                isSubmitting
                                    ? 'Confirming...'
                                    : 'Confirm booking',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<_BookingPayloadContext> _loadPayloadContext() async {
    final clientResult = await getit<GetCurrentClient>()();
    final stylistServicesResult = await getit<StylistsRepository>()
        .getStylistsServices(widget.stylist.id);

    final clientLookup = clientResult.fold<_ClientLookupResult>(
      (failure) => _ClientLookupResult(error: failure.message),
      (value) => _ClientLookupResult(customerId: value.id),
    );

    final customerId =
        clientLookup.customerId ?? SupabaseConfig.client.auth.currentUser?.id;

    if (customerId == null || customerId.trim().isEmpty) {
      throw Exception(
        clientLookup.error ?? 'No authenticated customer found for booking.',
      );
    }

    final stylistServices = stylistServicesResult
        .fold<List<StylistsServiceModel>>(
          (failure) => throw Exception(failure.message),
          (value) => value,
        );

    final matchingService = stylistServices
        .where((service) => service.isAvailable)
        .where((service) => service.serviceId == widget.serviceId)
        .cast<StylistsServiceModel?>()
        .firstWhere((service) => service != null, orElse: () => null);

    if (matchingService == null) {
      throw Exception(
        'This stylist is not available for the selected service.',
      );
    }

    return _BookingPayloadContext(
      customerId: customerId,
      stylistService: matchingService,
    );
  }

  void _submitBooking(
    BuildContext context,
    _BookingPayloadContext payloadContext,
    DateTime scheduledAt,
  ) {
    final address = _addressController.text.trim();
    final notes = _notesController.text.trim();

    if (address.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Please enter a booking address.')),
        );
      return;
    }

    final request = CreateBookingRequestModel(
      customerId: payloadContext.customerId,
      stylistId: widget.stylist.id,
      scheduledAt: scheduledAt,
      address: address,
      notes: notes.isEmpty ? null : notes,
      items: [
        CreateBookingServiceItemModel(
          serviceId: widget.serviceId,
          stylistServiceId: payloadContext.stylistService.id,
          quantity: 1,
        ),
      ],
    );

    context.read<BookingBloc>().add(CreateBookingWithServicesEvent(request));
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
      filled: true,
      fillColor: Colors.white.withAlpha(225),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.serviceName,
    required this.stylistName,
    required this.dateLabel,
    required this.timeLabel,
    required this.priceLabel,
  });

  final String serviceName;
  final String stylistName;
  final String dateLabel;
  final String timeLabel;
  final String priceLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(225),
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
            'with $stylistName',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF7C5342)),
          ),
          const SizedBox(height: 16),
          _SummaryRow(label: 'Date', value: dateLabel),
          _SummaryRow(label: 'Time', value: timeLabel),
          _SummaryRow(label: 'Estimated price', value: 'From $priceLabel'),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF7C5342)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF43261D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingErrorState extends StatelessWidget {
  const _BookingErrorState({required this.message});

  final String message;

  @override
  /*************  ✨ Windsurf Command ⭐  *************/
  /// Builds a centered widget with an amber warning icon and
  /// a centered text message.
  ///
  /// The icon is displayed first, followed by a 12px
  /// height gap, and then the text message.
  ///
  /// The text message is centered and fills the available width.
  ///
  /// The widget is padded by 24px on all sides.
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 44),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _BookingPayloadContext {
  const _BookingPayloadContext({
    required this.customerId,
    required this.stylistService,
  });

  final String customerId;
  final StylistsServiceModel stylistService;
}

class _ClientLookupResult {
  const _ClientLookupResult({this.customerId, this.error});

  final String? customerId;
  final String? error;
}
