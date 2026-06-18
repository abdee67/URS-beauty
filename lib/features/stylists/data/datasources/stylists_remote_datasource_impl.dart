import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/config/supabase_config.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/beauty_services/data/models/service_model.dart';
import 'package:urs_beauty/features/stylists/data/models/stylist_availability_slot_model.dart';
import 'package:urs_beauty/features/stylists/data/datasources/stylists_remote_data_source.dart';
import 'package:urs_beauty/features/stylists/data/models/stylists_availability_model.dart';
import 'package:urs_beauty/features/stylists/data/models/stylists_model.dart';
import 'package:urs_beauty/features/stylists/data/models/stylists_service_model.dart';

class StylistsRemoteDataSourceImpl implements StylistsRemoteDataSource {
  StylistsRemoteDataSourceImpl({SupabaseClient? client})
    : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  static const String _stylistsTable = 'stylists';
  static const String _stylistsServicesTable = 'stylists_services';
  static const String _stylistsAvailabilityTable = 'stylists_availability';
  static const String _stylistColumns =
      'id, business_name, description, service_radius_km, avg_rating, '
      'image_url, is_verified, total_reviews, longitude, latitude, '
      'created_at, updated_at';
  static const String _stylistsServiceColumns =
      'id, service_id, stylists_id, price, is_available';
  static const String _availabilityColumns =
      'id, stylists_id, day_of_week, start_time, end_time, is_available';
  static const String _serviceColumns =
      'id, name, description, category_id, duration_minutes, base_price, '
      'min_price, created_at, updated_at, is_active, icon_url';

  @override
  Future<List<StylistModel>> getStylists() {
    return _run(() async {
      final response = await _client
          .from(_stylistsTable)
          .select(_stylistColumns)
          .eq('is_verified', true)
          .order('avg_rating', ascending: false);

      return _mapStylistList(response);
    });
  }

  @override
  Future<List<StylistModel>> getStylistsByService(String serviceId) {
    return _run(() async {
      _requireValue(serviceId, 'Service id is required');

      final response = await _client
          .from(_stylistsServicesTable)
          .select('stylists($_stylistColumns)')
          .eq('service_id', serviceId)
          .eq('is_available', true);

      return _mapEmbeddedStylistsList(response);
    });
  }

  @override
  Future<StylistModel> getStylistDetail(String stylistId) {
    return _run(() async {
      _requireValue(stylistId, 'Stylist id is required');

      final response = await _client
          .from(_stylistsTable)
          .select(_stylistColumns)
          .eq('id', stylistId)
          .single();

      return _mapStylist(response);
    });
  }

  @override
  Future<List<StylistModel>> searchStylists(String query) {
    return _run(() async {
      final normalizedQuery = query.trim();
      if (normalizedQuery.isEmpty) {
        return getStylists();
      }

      final response = await _client
          .from(_stylistsTable)
          .select(_stylistColumns)
          .eq('is_verified', true)
          .or(
            'business_name.ilike.%$normalizedQuery%,'
            'description.ilike.%$normalizedQuery%',
          )
          .order('avg_rating', ascending: false);

      return _mapStylistList(response);
    });
  }

  @override
  Future<List<StylistsServiceModel>> getStylistsServices(String stylistId) {
    return _run(() async {
      _requireValue(stylistId, 'Stylist id is required');

      final response = await _client
          .from(_stylistsServicesTable)
          .select(_stylistsServiceColumns)
          .eq('stylists_id', stylistId)
          .order('service_id');

      return _mapStylistsServiceList(response);
    });
  }

  @override
  Future<List<StylistModel>> getNearByStylists(
    double latitude,
    double longitude,
    double radius,
  ) {
    return _run(() async {
      if (radius <= 0) {
        throw Failures(message: 'Radius must be greater than zero');
      }

      final response = await _client
          .from(_stylistsTable)
          .select(_stylistColumns)
          .eq('is_verified', true)
          .filter('latitude', 'gte', latitude - radius)
          .filter('latitude', 'lte', latitude + radius)
          .filter('longitude', 'gte', longitude - radius)
          .filter('longitude', 'lte', longitude + radius)
          .order('avg_rating', ascending: false);

      return _mapStylistList(response);
    });
  }

  @override
  Future<void> updateStylistsAvailability(
    StylistsAvailabilityModel availability,
  ) {
    return _run(() async {
      _validateAvailability(availability);

      await _client
          .from(_stylistsAvailabilityTable)
          .upsert(availability.toJson(), onConflict: 'id');
    });
  }

  @override
  Future<List<StylistsAvailabilityModel>> getStylistsAvailability(
    String stylistId,
  ) {
    return _run(() async {
      _requireValue(stylistId, 'Stylist id is required');

      final response = await _client
          .from(_stylistsAvailabilityTable)
          .select(_availabilityColumns)
          .eq('stylists_id', stylistId)
          .order('day_of_week')
          .order('start_time');

      return _mapAvailabilityList(response);
    });
  }

  @override
  Future<List<StylistsAvailabilityModel>> getStylistsAvailabilityByDay(
    String stylistId,
    String dayOfWeek,
  ) {
    return _run(() async {
      _requireValue(stylistId, 'Stylist id is required');
      _requireValue(dayOfWeek, 'Day of week is required');

      final response = await _client
          .from(_stylistsAvailabilityTable)
          .select(_availabilityColumns)
          .eq('stylists_id', stylistId)
          .eq('day_of_week', dayOfWeek)
          .order('start_time');

      return _mapAvailabilityList(response);
    });
  }

  @override
  Future<List<StylistAvailabilitySlotModel>> getStylistsAvailabilityByTime(
    String stylistId,
    String serviceId,
    DateTime selectedDate, {
    String? ignoredBookingId,
  }) {
    return _run(() async {
      _requireValue(stylistId, 'Stylist id is required');
      _requireValue(serviceId, 'Service id is required');

      final service = await _getService(serviceId);
      final serviceDuration = service.durationMinutes ?? 0;

      if (serviceDuration <= 0) {
        throw Failures(message: 'Selected service has an invalid duration');
      }

      final params = <String, dynamic>{
        'p_stylist_id': stylistId,
        'p_service_id': serviceId,
        'p_date': _dateParam(selectedDate),
      };

      final normalizedIgnoredBookingId = ignoredBookingId?.trim();
      if (normalizedIgnoredBookingId != null &&
          normalizedIgnoredBookingId.isNotEmpty) {
        params['p_ignored_booking_id'] = normalizedIgnoredBookingId;
      }

      final response = await _client.rpc('get_available_slots', params: params);

      return (response as List).map((item) {
        final data = item as Map;
        final startAt = _combineDateAndSlotTime(
          selectedDate,
          data['slot_time'].toString(),
        );
        return StylistAvailabilitySlotModel(
          startAt: startAt,
          endAt: startAt.add(Duration(minutes: serviceDuration)),
          isAvailable: true,
        );
      }).toList();
    });
  }

  @override
  Future<Position> getClientLocation() {
    return _run(() async {
      loc.Location location = loc.Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          throw LocationFailure(
            message:
                'Please enable location services to find stylists near you.',
          );
        }
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Failures(message: 'Location permissions are denied.');
      }

      if (permission == LocationPermission.deniedForever) {
        throw Failures(
          message:
              'Location permissions are permanently denied, we cannot request permissions.',
        );
      }

      return Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    });
  }

  @override
  Future<List<StylistModel>> fetchStylistsForService({
    required String serviceId,
    required double clientLat,
    required double clientLng,
    required DateTime requestedDateTime,
    int limit = 20,
    int offset = 0,
  }) {
    return _run(() async {
      _requireValue(serviceId, 'Service id is required');

      final response = await _client.rpc(
        'get_stylists_for_service',
        params: <String, dynamic>{
          'p_service_id': serviceId,
          'p_client_lat': clientLat,
          'p_client_lng': clientLng,
          'p_requested_day': DateFormat('EEE').format(requestedDateTime),
          'p_requested_time': DateFormat('HH:mm:ss').format(requestedDateTime),
          'p_requested_date': _dateParam(requestedDateTime),
          'p_limit': limit,
          'p_offset': offset,
        },
      );
      if (kDebugMode) {
        developer.log('stylists for service: $response');
      }

      return (response as List)
          .map(
            (row) =>
                StylistModel.fromJson(Map<String, dynamic>.from(row as Map)),
          )
          .toList();
    });
  }

  @override
  Future<List<StylistAvailabilitySlotModel>> fetchAvailableSlots({
    required String stylistId,
    required String serviceId,
    required DateTime date,
    String? ignoredBookingId,
  }) {
    return _run(() async {
      _requireValue(stylistId, 'Stylist id is required');
      _requireValue(serviceId, 'Service id is required');

      final durationMinutes = await _getServiceDuration(serviceId);
      if (durationMinutes <= 0) {
        throw Failures(message: 'Selected service has an invalid duration');
      }

      final params = <String, dynamic>{
        'p_stylist_id': stylistId,
        'p_service_id': serviceId,
        'p_date': _dateParam(date),
      };

      final normalizedIgnoredBookingId = ignoredBookingId?.trim();
      if (normalizedIgnoredBookingId != null &&
          normalizedIgnoredBookingId.isNotEmpty) {
        params['p_ignored_booking_id'] = normalizedIgnoredBookingId;
      }

      final response = await _client.rpc('get_available_slots', params: params);

      return (response as List).map((row) {
        final slotValue = row is Map ? row['slot_time'] : row;
        final startAt = _combineDateAndTime(date, slotValue.toString());
        return StylistAvailabilitySlotModel(
          startAt: startAt,
          endAt: startAt.add(Duration(minutes: durationMinutes)),
          isAvailable: true,
        );
      }).toList();
    });
  }

  Future<int> _getServiceDuration(String serviceId) async {
    final response = await _client
        .from('services')
        .select('duration_minutes')
        .eq('id', serviceId)
        .single();

    final value = response['duration_minutes'];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String && value.trim().isNotEmpty) {
      return int.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }

  Future<T> _run<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on LocationFailure {
      rethrow;
    } on Failures {
      rethrow;
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        developer.log(
          'StylistsRemoteDataSourceImpl: ${e.message} ${e.details} ${e.hint}',
          name: 'StylistsRemoteDataSourceImpl',
        );
      }
      throw Failures(message: e.message);
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'StylistsRemoteDataSourceImpl: ${e.toString()}',
          name: 'StylistsRemoteDataSourceImpl',
        );
      }
      throw Failures(message: e.toString());
    }
  }

  List<StylistModel> _mapStylistList(dynamic response) {
    return (response as List)
        .map(
          (item) =>
              StylistModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  List<StylistModel> _mapEmbeddedStylistsList(dynamic response) {
    final stylistsById = <String, StylistModel>{};

    for (final item in response as List) {
      final data = (item as Map)['stylists'];
      if (data is! Map) {
        continue;
      }

      final stylist = StylistModel.fromJson(Map<String, dynamic>.from(data));
      if (stylist.isVerified) {
        stylistsById[stylist.id] = stylist;
      }
    }

    final stylists = stylistsById.values.toList();
    stylists.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    return stylists;
  }

  List<StylistsServiceModel> _mapStylistsServiceList(dynamic response) {
    return (response as List)
        .map(
          (item) => StylistsServiceModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  List<StylistsAvailabilityModel> _mapAvailabilityList(dynamic response) {
    return (response as List)
        .map(
          (item) => StylistsAvailabilityModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  ServiceModel _mapService(dynamic response) {
    return ServiceModel.fromJson(Map<String, dynamic>.from(response as Map));
  }

  StylistModel _mapStylist(dynamic response) {
    return StylistModel.fromJson(Map<String, dynamic>.from(response as Map));
  }

  Future<ServiceModel> _getService(String serviceId) async {
    final response = await _client
        .from('services')
        .select(_serviceColumns)
        .eq('id', serviceId)
        .single();

    return _mapService(response);
  }

  DateTime _combineDateAndSlotTime(DateTime date, String value) {
    final normalized = value.trim();
    final parts = normalized.split(':');

    if (parts.length < 2) {
      throw Failures(message: 'Invalid availability time: $value');
    }

    final hour = int.tryParse(parts[0]) ?? -1;
    final minute = int.tryParse(parts[1]) ?? -1;

    if (hour < 0 || minute < 0) {
      throw Failures(message: 'Invalid availability time: $value');
    }

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  String _dateParam(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  void _validateAvailability(StylistsAvailabilityModel availability) {
    _requireValue(availability.stylistsId, 'Stylist id is required');
    _requireValue(availability.dayOfWeek, 'Day of week is required');
    _requireValue(availability.startTime, 'Start time is required');
    _requireValue(availability.endTime, 'End time is required');
  }

  void _requireValue(String value, String message) {
    if (value.trim().isEmpty) {
      throw Failures(message: message);
    }
  }

  DateTime _combineDateAndTime(DateTime date, String value) {
    final parts = value.trim().split(':');
    if (parts.length < 2) {
      throw Failures(message: 'Invalid availability time: $value');
    }

    final hour = int.tryParse(parts[0]) ?? -1;
    final minute = int.tryParse(parts[1]) ?? -1;
    if (hour < 0 || minute < 0) {
      throw Failures(message: 'Invalid availability time: $value');
    }

    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}
