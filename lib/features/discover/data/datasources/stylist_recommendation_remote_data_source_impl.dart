import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/config/supabase_config.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/discover/data/datasources/stylist_recommendation_remote_data_source.dart';
import 'package:urs_beauty/features/discover/data/models/stylist_card_model.dart';
import 'package:urs_beauty/features/stylists/data/models/stylist_availability_slot_model.dart';

class StylistRecommendationRemoteDataSourceImpl
    implements StylistRecommendationRemoteDataSource {
  StylistRecommendationRemoteDataSourceImpl({SupabaseClient? client})
    : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  @override
  Future<Position> getClientLocation() {
    return _run(() async {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationFailure(
          message: 'Please enable location services to find stylists near you.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw LocationFailure(
          message: 'Location permission is required to find nearby stylists.',
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
  Future<List<StylistCardModel>> fetchStylists({
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

      return (response as List)
          .map(
            (row) => StylistCardModel.fromJson(
              Map<String, dynamic>.from(row as Map),
            ),
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
      throw Failures(message: e.message);
    } catch (e) {
      throw Failures(message: e.toString());
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

  String _dateParam(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  void _requireValue(String value, String message) {
    if (value.trim().isEmpty) {
      throw Failures(message: message);
    }
  }
}
