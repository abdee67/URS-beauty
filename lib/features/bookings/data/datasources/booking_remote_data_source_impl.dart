import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/config/supabase_config.dart';
import 'package:urs_beauty/core/errors/exceptions/booking_exceptions.dart';
import 'package:urs_beauty/core/errors/failures/booking_failures.dart';
import 'package:urs_beauty/features/bookings/data/datasources/booking_remote_data_source.dart';
import 'package:urs_beauty/features/bookings/data/models/booking_model.dart';
import 'package:urs_beauty/features/bookings/data/models/booking_services_model.dart';
import 'package:urs_beauty/features/bookings/data/models/create_booking_request_model.dart';
import 'package:urs_beauty/features/bookings/data/models/reschedule_booking_request_model.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart';

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  BookingRemoteDataSourceImpl({SupabaseClient? client})
    : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  static const String _bookingColumns =
      'id, customer, stylist, status, is_reviewed, rescheduled_from, '
      'rescheduled_count, notes, address, total_amount, scheduled_at, end_at, '
      'created_at, updated_at, payment_method, payment_status, currency, '
      'paid_amount, refund_amount, commission_amount, stylist_earning, '
      'stylist_profile:stylists(business_name), '
      'booked_services:booking_services(service_name)';
  static const String _bookingServicesColumns =
      'id, booking_id, service_name, service_id, stylist_service_id, '
      'quantity, price_at_booking, duration_at_booking';

  @override
  Future<BookingModel> createBooking(BookingModel booking) {
    return bookingDataSourceOperation(() async {
      final response = await _client
          .from('bookings')
          .insert(booking.createBookingPayload(booking))
          .select(_bookingColumns)
          .single();

      return _mapBooking(response);
    });
  }

  @override
  Future<BookingModel> createBookingWithServices(
    CreateBookingRequestModel request,
  ) {
    return bookingDataSourceOperation(() async {
      _validateCreateBookingRequest(request);

      final response = await _client.rpc(
        'create_booking_with_services',
        params: request.toRpcParams(),
      );

      return _mapRpcBooking(response);
    });
  }

  @override
  Future<BookingModel> updateBooking(BookingModel booking) {
    return bookingDataSourceOperation(() async {
      requireValue(booking.id, 'Booking id is required for update');

      final response = await _client
          .from('bookings')
          .update(booking.updateBookingPayload(booking))
          .eq('id', booking.id)
          .select(_bookingColumns)
          .single();

      return _mapBooking(response);
    });
  }

  @override
  Future<BookingModel> cancelBooking(String bookingId) {
    return bookingDataSourceOperation(() async {
      requireValue(bookingId, 'Booking id is required to cancel a booking');

      final response = await _client.functions.invoke(
        'cancel-card-booking',
        body: {'booking_id': bookingId},
      );

      final data = response.data;
      if (data is! Map && data is! Map<String, dynamic>) {
        throw const BookingResponseException(
          message: 'Unexpected response from cancel-card-booking function.',
        );
      }

      final payload = Map<String, dynamic>.from(data as Map);
      final booking = payload['booking'];
      if (booking is! Map && booking is! Map<String, dynamic>) {
        throw const BookingResponseException(
          message: 'cancel-card-booking did not return an updated booking.',
        );
      }

      return _mapBooking(booking);
    });
  }

  @override
  Future<List<BookingModel>> getBookings() {
    return bookingDataSourceOperation(() async {
      final response = await _client
          .from('bookings')
          .select(_bookingColumns)
          .order('scheduled_at', ascending: false);

      return _mapBookingList(response);
    });
  }

  @override
  Future<BookingModel> getBookingById(String bookingId) {
    return bookingDataSourceOperation(() async {
      requireValue(bookingId, 'Booking id is required');

      final response = await _client
          .from('bookings')
          .select(_bookingColumns)
          .eq('id', bookingId)
          .single();

      return _mapBooking(response);
    });
  }

  @override
  Future<List<BookingServicesModel>> getBookingServices(String bookingId) {
    return bookingDataSourceOperation(() async {
      requireValue(bookingId, 'Booking id is required');

      final response = await _client
          .from('booking_services')
          .select(_bookingServicesColumns)
          .eq('booking_id', bookingId)
          .order('id');

      return _mapBookingServicesList(response);
    });
  }

  @override
  Future<List<BookingModel>> getBookingsByCustomerId(String customerId) {
    return bookingDataSourceOperation(() async {
      requireValue(customerId, 'Customer id is required');

      final response = await _client
          .from('bookings')
          .select(_bookingColumns)
          .eq('customer', customerId)
          .order('scheduled_at', ascending: false);

      return _mapBookingList(response);
    });
  }

  @override
  Future<List<BookingModel>> getBookingsByStylistId(String stylistId) {
    return bookingDataSourceOperation(() async {
      requireValue(stylistId, 'Stylist id is required');

      final response = await _client
          .from('bookings')
          .select(_bookingColumns)
          .eq('stylist', stylistId)
          .order('scheduled_at', ascending: false);

      return _mapBookingList(response);
    });
  }

  @override
  Future<List<BookingModel>> getBookingsByStatus(BookingStatus status) {
    return bookingDataSourceOperation(() async {
      final normalizedStatus = _normalizeStatus(status.name);

      final response = await _client
          .from('bookings')
          .select(_bookingColumns)
          .eq('status', normalizedStatus)
          .order('scheduled_at', ascending: false);

      return _mapBookingList(response);
    });
  }

  @override
  Future<BookingModel> rescheduleBooking(
    RescheduleBookingRequestModel request,
  ) {
    return bookingDataSourceOperation(() async {
      requireValue(request.bookingId, 'Booking id is required');
      requireValue(request.stylistId, 'Stylist id is required');

      final response = await _client.rpc(
        'reschedule_booking',
        params: request.toRpcParams(),
      );

      return _mapRpcBooking(response);
    });
  }

  @override
  Future<BookingModel> addNotesToBooking(String bookingId, String notes) {
    return _updateBookingFields(bookingId, {
      'notes': notes.trim().isEmpty ? null : notes.trim(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  @override
  Future<BookingModel> updateBookingStatus(String bookingId, String status) {
    return _updateBookingFields(bookingId, {
      'status': _normalizeStatus(status),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  @override
  Future<List<BookingModel>> searchBookings(String query) {
    return bookingDataSourceOperation(() async {
      final normalizedQuery = query.trim();
      if (normalizedQuery.isEmpty) {
        return getBookings();
      }

      final response = await _client
          .from('bookings')
          .select(_bookingColumns)
          .ilike('notes', '%$normalizedQuery%')
          .order('scheduled_at', ascending: false);

      return _mapBookingList(response);
    });
  }

  Future<BookingModel> _updateBookingFields(
    String bookingId,
    Map<String, dynamic> changes,
  ) {
    return bookingDataSourceOperation(() async {
      requireValue(bookingId, 'Booking id is required');

      final response = await _client
          .from('bookings')
          .update(changes)
          .eq('id', bookingId)
          .select(_bookingColumns)
          .single();

      return _mapBooking(response);
    });
  }

  List<BookingModel> _mapBookingList(dynamic response) {
    return (response as List)
        .map(
          (item) =>
              BookingModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  List<BookingServicesModel> _mapBookingServicesList(dynamic response) {
    return (response as List)
        .map(
          (item) => BookingServicesModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  BookingModel _mapBooking(dynamic response) {
    return BookingModel.fromJson(Map<String, dynamic>.from(response as Map));
  }

  Future<BookingModel> _mapRpcBooking(dynamic response) async {
    if (response is List) {
      if (response.isEmpty) {
        throw const BookingResponseException(
          message: 'Booking creation returned no data.',
        );
      }
      return _mapRpcBooking(response.first);
    }

    if (response is Map) {
      final data = Map<String, dynamic>.from(response);
      if (data['booking'] is Map) {
        return _mapBooking(data['booking']);
      }
      if (data['booking_id'] != null && data['customer'] == null) {
        return getBookingById(data['booking_id'].toString());
      }
      return _mapBooking(data);
    }

    if (response is String && response.trim().isNotEmpty) {
      return getBookingById(response.trim());
    }

    throw const BookingResponseException(
      message: 'Unexpected response from create_booking_with_services',
    );
  }

  String _normalizeStatus(String status) {
    final normalizedStatus = status.split('.').last.trim().toLowerCase();
    requireValue(normalizedStatus, 'Booking status is required');

    if (!BookingStatus.values.any((value) => value.name == normalizedStatus)) {
      throw BookingValidationException(
        message: 'Invalid booking status: $status',
      );
    }

    return normalizedStatus;
  }

  void _validateCreateBookingRequest(CreateBookingRequestModel request) {
    requireValue(request.customerId, 'Customer id is required');
    requireValue(request.stylistId, 'Stylist id is required');
    requireValue(request.addressId, 'Booking address is required');

    if (request.items.isEmpty) {
      throw const BookingValidationException(
        message: 'At least one service item is required',
      );
    }

    for (final item in request.items) {
      if (item.serviceId.trim().isEmpty) {
        throw const BookingValidationException(
          message: 'Each booking item must have a valid service',
        );
      }
      if (item.stylistServiceId.trim().isEmpty) {
        throw const BookingValidationException(
          message: 'Each booking item must have a valid stylist service',
        );
      }
      if (item.quantity <= 0) {
        throw const BookingValidationException(
          message: 'Each booking item must have a quantity greater than zero',
        );
      }
    }
  }
}
