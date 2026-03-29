import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/config/supabase_config.dart';
import 'package:urs_beauty/core/errors/failures.dart';
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
      'id, stylists_Id, day_of_Week, start_time, end_time, isAvailable';

  @override
  Future<List<StylistModel>> getStylists() {
    return _run(() async {
      final response = await _client
          .from(_stylistsTable)
          .select(_stylistColumns)
          .eq('is_verified', true)
          .order('avg_rating', ascending: false)
          .limit(5);

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
          .eq('stylists_Id', stylistId)
          .order('day_of_Week')
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
          .eq('stylists_Id', stylistId)
          .eq('day_of_Week', dayOfWeek)
          .order('start_time');

      return _mapAvailabilityList(response);
    });
  }

  @override
  Future<List<StylistsAvailabilityModel>> getStylistsAvailabilityByTime(
    String stylistId,
    String dayOfWeek,
    String time,
  ) {
    return _run(() async {
      _requireValue(stylistId, 'Stylist id is required');
      _requireValue(dayOfWeek, 'Day of week is required');
      _requireValue(time, 'Time is required');

      final response = await _client
          .from(_stylistsAvailabilityTable)
          .select(_availabilityColumns)
          .eq('stylists_Id', stylistId)
          .eq('day_of_Week', dayOfWeek)
          .lte('start_time', time)
          .gte('end_time', time)
          .order('start_time');

      return _mapAvailabilityList(response);
    });
  }

  Future<T> _run<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on Failures {
      rethrow;
    } on PostgrestException catch (e) {
      throw Failures(message: e.message);
    } catch (e) {
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

  StylistModel _mapStylist(dynamic response) {
    return StylistModel.fromJson(Map<String, dynamic>.from(response as Map));
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
}
