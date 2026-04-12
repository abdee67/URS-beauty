import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/config/supabase_config.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/beauty_services/data/models/service_model.dart';
import 'package:urs_beauty/features/bookings/data/models/booking_model.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart';
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
  static const String _bookingColumns =
      'id, customer, stylist, status, notes, address, total_amount, '
      'scheduled_at, end_at, created_at, updated_at';

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
    DateTime selectedDate,
  ) {
    return _run(() async {
      _requireValue(stylistId, 'Stylist id is required');
      _requireValue(serviceId, 'Service id is required');

      final service = await _getService(serviceId);
      final serviceDuration = service.durationMinutes ?? 0;

      if (serviceDuration <= 0) {
        throw Failures(message: 'Selected service has an invalid duration');
      }

      final dayOfWeek = _dayOfWeekLabel(selectedDate);
      final availabilityResponse = await _client
          .from(_stylistsAvailabilityTable)
          .select(_availabilityColumns)
          .eq('stylists_id', stylistId)
          .eq('day_of_week', dayOfWeek)
          .eq('is_available', true)
          .order('start_time');

      final availabilityWindows = _mapAvailabilityList(availabilityResponse);
      if (availabilityWindows.isEmpty) {
        return const <StylistAvailabilitySlotModel>[];
      }

      final bookings = await _getBookingsForDate(stylistId, selectedDate);
      return _generateTimeSlots(
        selectedDate: selectedDate,
        durationMinutes: serviceDuration,
        availabilityWindows: availabilityWindows,
        bookings: bookings,
      );
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

  ServiceModel _mapService(dynamic response) {
    return ServiceModel.fromJson(Map<String, dynamic>.from(response as Map));
  }

  List<BookingModel> _mapBookingList(dynamic response) {
    return (response as List)
        .map(
          (item) =>
              BookingModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
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

  Future<List<BookingModel>> _getBookingsForDate(
    String stylistId,
    DateTime selectedDate,
  ) async {
    final startOfDayLocal = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final endOfDayLocal = startOfDayLocal.add(const Duration(days: 1));
    final startOfDayUtc = startOfDayLocal.toUtc();
    final endOfDayUtc = endOfDayLocal.toUtc();

    final response = await _client
        .from('bookings')
        .select(_bookingColumns)
        .eq('stylist', stylistId)
        .lt('scheduled_at', endOfDayUtc.toIso8601String())
        .gt('end_at', startOfDayUtc.toIso8601String())
        .order('scheduled_at');

    return _mapBookingList(response)
        .where(
          (booking) =>
              booking.status == BookingStatus.pending ||
              booking.status == BookingStatus.completed,
        )
        .toList();
  }

  List<StylistAvailabilitySlotModel> _generateTimeSlots({
    required DateTime selectedDate,
    required int durationMinutes,
    required List<StylistsAvailabilityModel> availabilityWindows,
    required List<BookingModel> bookings,
  }) {
    final slotsByStart = <DateTime, StylistAvailabilitySlotModel>{};
    final cutoff = _slotCutoffForDate(selectedDate);
    final slotDuration = Duration(minutes: durationMinutes);

    for (final window in availabilityWindows) {
      final windowStart = _combineDateAndTime(selectedDate, window.startTime);
      final windowEnd = _combineDateAndTime(selectedDate, window.endTime);

      if (!window.isAvailable || !windowEnd.isAfter(windowStart)) {
        continue;
      }

      var slotStart = windowStart;
      while (!slotStart.add(slotDuration).isAfter(windowEnd)) {
        final slotEnd = slotStart.add(slotDuration);
        final isBlockedByBooking = bookings.any(
          (booking) =>
              slotStart.isBefore(booking.endAt) &&
              slotEnd.isAfter(booking.scheduledAt),
        );
        final isPastCutoff = cutoff != null && slotStart.isBefore(cutoff);

        slotsByStart[slotStart] = StylistAvailabilitySlotModel(
          startAt: slotStart,
          endAt: slotEnd,
          isAvailable: !isBlockedByBooking && !isPastCutoff,
        );
        slotStart = slotStart.add(slotDuration);
      }
    }

    final slots = slotsByStart.values.toList()
      ..sort((first, second) => first.startAt.compareTo(second.startAt));
    return slots;
  }

  DateTime? _slotCutoffForDate(DateTime selectedDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    if (targetDate != today) {
      return null;
    }

    return now.add(const Duration(minutes: 30));
  }

  DateTime _combineDateAndTime(DateTime date, String value) {
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

  String _dayOfWeekLabel(DateTime date) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[date.weekday - 1];
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
