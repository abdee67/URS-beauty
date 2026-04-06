import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/config/supabase_config.dart';
import 'package:urs_beauty/features/auth/data/models/customer_address_model.dart';
import 'package:urs_beauty/features/auth/domain/entities/customer_entity.dart';
import 'package:urs_beauty/features/auth/domain/usecases/get_current_client.dart';
import 'package:urs_beauty/features/bookings/data/models/create_booking_request_model.dart';
import 'package:urs_beauty/features/bookings/data/models/create_booking_service_item_model.dart';
import 'package:urs_beauty/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:urs_beauty/features/bookings/presentation/screens/booking_success_screen.dart';
import 'package:urs_beauty/features/bookings/presentation/widgets/address_option_card_widget.dart';
import 'package:urs_beauty/features/bookings/presentation/widgets/booking_error_widget.dart';
import 'package:urs_beauty/features/bookings/presentation/widgets/empty_address_state_widget.dart';
import 'package:urs_beauty/features/bookings/presentation/widgets/selected_address_preview_widget.dart';
import 'package:urs_beauty/features/bookings/presentation/widgets/summary_card_widget.dart';
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
  late final TextEditingController _notesController;
  late final Future<_BookingPayloadContext> _payloadContextFuture;
  final List<CustomerAddressModel> _newAddresses = <CustomerAddressModel>[];
  String? _selectedAddressId;
  bool _isSavingCurrentLocation = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    _payloadContextFuture = _loadPayloadContext();
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
                    return BookingErrorState(
                      message: snapshot.error.toString(),
                    );
                  }

                  final payloadContext = snapshot.data;
                  if (payloadContext == null) {
                    return const BookingErrorState(
                      message: 'Unable to prepare booking details.',
                    );
                  }

                  final addresses = _resolvedAddresses(payloadContext);
                  final selectedAddressId =
                      _selectedAddressId ?? payloadContext.customer.defaultAddress?.id;
                  final selectedAddress = addresses
                      .where((address) => address.id == selectedAddressId)
                      .cast<CustomerAddressModel?>()
                      .firstWhere((address) => address != null, orElse: () => null);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SummaryCard(
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
                        if (addresses.isEmpty)
                          AddressEmptyState(
                            isBusy: _isSavingCurrentLocation,
                            onUseCurrentLocation: () => _saveCurrentLocationAddress(
                              payloadContext.customer,
                            ),
                          )
                        else ...[
                          ...addresses.map(
                            (address) => AddressOptionCard(
                              address: address,
                              isSelected: address.id == selectedAddressId,
                              onTap: () {
                                setState(() {
                                  _selectedAddressId = address.id;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _isSavingCurrentLocation
                                ? null
                                : () => _saveCurrentLocationAddress(
                                      payloadContext.customer,
                                    ),
                            icon: _isSavingCurrentLocation
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.my_location_rounded),
                            label: Text(
                              _isSavingCurrentLocation
                                  ? 'Saving current location...'
                                  : 'Use current location as new address',
                            ),
                          ),
                        ],
                        if (selectedAddress != null) ...[
                          const SizedBox(height: 18),
                          SelectedAddressPreview(address: selectedAddress),
                        ],
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
                                      selectedAddressId,
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

  List<CustomerAddressModel> _resolvedAddresses(_BookingPayloadContext context) {
    final existing = context.addresses;
    final merged = <CustomerAddressModel>[...existing];
    for (final address in _newAddresses) {
      final alreadyExists = merged.any((item) => item.id == address.id);
      if (!alreadyExists) {
        merged.add(address);
      }
    }
    return merged;
  }

  Future<_BookingPayloadContext> _loadPayloadContext() async {
    final customerResult = await getit<GetCurrentCustomer>()();
    final stylistServicesResult =
        await getit<StylistsRepository>().getStylistsServices(widget.stylist.id);

    final customer = customerResult.fold<CustomerEntity>(
      (failure) => throw Exception(failure.message),
      (value) => value,
    );

    if (customer.id.trim().isEmpty) {
      throw Exception('No authenticated customer found for booking.');
    }

    final stylistServices = stylistServicesResult.fold<List<StylistsServiceModel>>(
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

    final addresses = customer.addresses
        .map((address) => _toAddressModel(address, customer.id))
        .toList();

    return _BookingPayloadContext(
      customer: customer,
      stylistService: matchingService,
      addresses: addresses,
    );
  }

  CustomerAddressModel _toAddressModel(dynamic address, String customerId) {
    if (address is CustomerAddressModel) {
      return address;
    }

    return CustomerAddressModel(
      id: address.id.toString(),
      customerId: customerId,
      addressLine1: address.addressLine1?.toString() ?? '',
      addressLine2: address.addressLine2?.toString() ?? '',
      city: address.city?.toString() ?? '',
      state: address.state?.toString() ?? '',
      postalCode: address.postalCode?.toString() ?? '',
      country: address.country?.toString() ?? '',
      latitude: (address.latitude as num?)?.toDouble() ?? 0,
      longitude: (address.longitude as num?)?.toDouble() ?? 0,
      isDefault: address.isDefault == true,
      createdAt: address.createdAt is DateTime
          ? address.createdAt as DateTime
          : DateTime.now(),
      updatedAt: address.updatedAt is DateTime
          ? address.updatedAt as DateTime
          : DateTime.now(),
    );
  }

  Future<void> _saveCurrentLocationAddress(CustomerEntity customer) async {
    if (_isSavingCurrentLocation) {
      return;
    }

    setState(() {
      _isSavingCurrentLocation = true;
    });

    try {
      final permission = await _ensureLocationPermission();
      if (!permission) {
        throw Exception('Location permission is required to use your current address.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final placemark = placemarks.isNotEmpty ? placemarks.first : null;

      final addressLine1 = _composeAddressLine1(placemark);
      final addressLine2 = _composeAddressLine2(placemark);
      final city = placemark?.locality ?? placemark?.subAdministrativeArea ?? '';
      final state = placemark?.administrativeArea ?? '';
      final postalCode = placemark?.postalCode ?? '';
      final country = placemark?.country ?? '';
      final now = DateTime.now().toIso8601String();

      final payload = <String, dynamic>{
        'customer_id': customer.id,
        'address_line1': addressLine1,
        'address_line2': addressLine2,
        'city': city,
        'state': state,
        'postal_code': postalCode,
        'country': country,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'is_default': customer.addresses.isEmpty && _newAddresses.isEmpty,
        'created_at': now,
        'updated_at': now,
      };

      final response = await SupabaseConfig.client
          .from('customer_addresses')
          .insert(payload)
          .select()
          .single();

      final savedAddress = CustomerAddressModel.fromJson(
        Map<String, dynamic>.from(response),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _newAddresses.add(savedAddress);
        _selectedAddressId = savedAddress.id;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Current location saved as address.')),
        );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isSavingCurrentLocation = false;
        });
      }
    }
  }

  Future<bool> _ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are turned off on this device.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
   return Future.error('Location permissions are denied');
    }

        if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 

    return true;
  }

  String _composeAddressLine1(Placemark? placemark) {
    final parts = <String>[
      if ((placemark?.street ?? '').trim().isNotEmpty) placemark!.street!.trim(),
      if ((placemark?.subLocality ?? '').trim().isNotEmpty)
        placemark!.subLocality!.trim(),
    ];

    if (parts.isEmpty) {
      return 'Current location';
    }

    return parts.join(', ');
  }

  String _composeAddressLine2(Placemark? placemark) {
    final parts = <String>[
      if ((placemark?.thoroughfare ?? '').trim().isNotEmpty)
        placemark!.thoroughfare!.trim(),
      if ((placemark?.subThoroughfare ?? '').trim().isNotEmpty)
        placemark!.subThoroughfare!.trim(),
    ];

    return parts.join(', ');
  }

  void _submitBooking(
    BuildContext context,
    _BookingPayloadContext payloadContext,
    DateTime scheduledAt,
    String? selectedAddressId,
  ) {
    final notes = _notesController.text.trim();
    final addressId = selectedAddressId?.trim() ?? '';

    if (addressId.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Please choose a booking address.')),
        );
      return;
    }

    final request = CreateBookingRequestModel(
      customerId: payloadContext.customer.id,
      stylistId: widget.stylist.id,
      scheduledAt: scheduledAt,
      addressId: addressId,
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
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s?(AM|PM)$').firstMatch(normalized);

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



class _BookingPayloadContext {
  const _BookingPayloadContext({
    required this.customer,
    required this.stylistService,
    required this.addresses,
  });

  final CustomerEntity customer;
  final StylistsServiceModel stylistService;
  final List<CustomerAddressModel> addresses;
}




