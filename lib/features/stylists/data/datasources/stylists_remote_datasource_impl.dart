import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/config/supabase_config.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/stylists/data/datasources/stylists_remote_data_source.dart';
import 'package:urs_beauty/features/stylists/data/models/stylists_availability_model.dart';
import 'package:urs_beauty/features/stylists/data/models/stylists_model.dart';
import 'package:urs_beauty/features/stylists/data/models/stylists_service_model.dart';

class StylistsRemoteDataSourceImpl implements StylistsRemoteDataSource {
  @override
  Future<List<StylistModel>> getStylists() async {
    try {
      final response = await SupabaseConfig.client
          .from('stylists')
          .select('''
      id,
      business_name,
      description,
      service_radius_km,
      avg_rating,
      image_url,
      stylists_services (
        service_id,
        services (
          name,
          description
        )
      )
    ''')
          .eq('is_verified', true)
          .limit(5);

      return response.map(StylistModel.fromJson).toList();
    } on PostgrestException catch (e) {
      throw Failures(message: e.message);
    } catch (e) {
      throw Failures(message: e.toString());
    }
  }

  @override
  Future<List<StylistModel>> searchStylists(String query) async {
    try {
      final response = await SupabaseConfig.client
          .from('stylists')
          .select('''
      id,
      business_name,
      description,
      service_radius_km,
      avg_rating,
      image_url,
      stylists_services (
        service_id,
        services (
          name,
          description
        )
      )
    ''')
          .or('name.ilike.%$query%, business_name.ilike.%$query%')
          .eq('is_verified', true);

      return response.map(StylistModel.fromJson).toList();
    } on PostgrestException catch (e) {
      throw Failures(message: e.message);
    } catch (e) {
      throw Failures(message: e.toString());
    }
  }

  @override
  Future<List<StylistsServiceModel>> getStylistsServices(
    String stylistId,
  ) async {
    try {
      final response = await SupabaseConfig.client
          .from('stylists_services')
          .select('''
price,
      stylists (
        id,
        business_name,
        description,
        service_radius_km,
        avg_rating,
        image_url
      ),
      services (
        id,
        name,
        description
      )
    ''')
          .eq('stylists_id', stylistId);
      return (response as List).map((e) {
        return StylistsServiceModel.fromJson(e);
      }).toList();
    } on PostgrestException catch (e) {
      throw Failures(message: e.message);
    } catch (e) {
      throw Failures(message: e.toString());
    }
  }

  @override
  Future<List<StylistModel>> getStylistsByService(
    String serviceId,
  ) async {
    try {
      final response = await SupabaseConfig.client
          .from('stylists_services')
          .select('''
price,
      stylists (
        id,
        business_name,
        description,
        service_radius_km,
        avg_rating,
        image_url
      )
    ''')
          .eq('service_id', serviceId);
        return (response as List).map((e) {
        final stylistData = e['stylists'];
        stylistData['price'] = e['price'];
        return StylistModel.fromJson(stylistData);
      }).toList();

    } on PostgrestException catch (e) {
      throw Failures(message: e.message);
    } catch (e) {
      throw Failures(message: e.toString());
    }
  }

  @override
  Future<StylistModel> getStylistDetail(String stylistId) async {
    try {
      final response = await SupabaseConfig.client
          .from('stylists')
          .select('''
      id,
      business_name,
      description,
      service_radius_km,
      avg_rating,
      image_url,
      stylists_services (
        service_id,
        services (
          name,
          description
        )
      )
    ''')
          .eq('id', stylistId)
          .single();

      return StylistModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Failures(message: e.message);
    } catch (e) {
      throw Failures(message: e.toString());
    }
  }

  @override
  Future<List<StylistsAvailabilityModel>> getStylistsAvailability(
    String stylistId,
  ) async {
    try {
      final response = await SupabaseConfig.client
          .from('stylists_availability')
          .select(
            'id, stylists_Id, day_of_Week, start_time, end_time, isAvailable',
          )
          .eq('stylists_Id', stylistId);

      return response.map(StylistsAvailabilityModel.fromJson).toList();
    } on PostgrestException catch (e) {
      throw Failures(message: e.message);
    } catch (e) {
      throw Failures(message: e.toString());
    }
  }

  @override
  Future<List<StylistModel>> getNearByStylists(
    double latitude,
    double longitude,
    double radius,
  ) async {
    try {
      final response = await SupabaseConfig.client
          .from('stylists')
          .select('''
      id,
      business_name,
      description,
      service_radius_km,
      avg_rating,
      image_url,
      longitude,
      latitude
    ''')
          .filter('latitude', 'gte', latitude - radius)
          .filter('latitude', 'lte', latitude + radius)
          .filter('longitude', 'gte', longitude - radius)
          .filter('longitude', 'lte', longitude + radius);

      return response.map(StylistModel.fromJson).toList();
    } on PostgrestException catch (e) {
      throw Failures(message: e.message);
    } catch (e) {
      throw Failures(message: e.toString());
    }
  }

  @override
  Future<void> updateStylistsAvailability(
    StylistsAvailabilityModel availability,
  ) async {
    try {
      await SupabaseConfig.client
          .from('stylists_availability')
          .upsert(availability.toJson(), onConflict: 'id');
    } on PostgrestException catch (e) {
      throw Failures(message: e.message);
    } catch (e) {
      throw Failures(message: e.toString());
    }
  }

  @override
  Future<List<StylistsAvailabilityModel>> getStylistsAvailabilityByDay(
    String stylistId,
    String dayOfWeek,
  ) async {
    try {
      final response = await SupabaseConfig.client
          .from('stylists_availability')
          .select(
            'id, stylists_Id, day_of_Week, start_time, end_time, isAvailable',
          )
          .eq('stylists_Id', stylistId)
          .eq('day_of_Week', dayOfWeek);

      return response.map(StylistsAvailabilityModel.fromJson).toList();
    } on PostgrestException catch (e) {
      throw Failures(message: e.message);
    } catch (e) {
      throw Failures(message: e.toString());
    }
  }

  @override
  Future<List<StylistsAvailabilityModel>> getStylistsAvailabilityByTime(
    String stylistId,
    String dayOfWeek,
    String time,
  ) async {
    try {
      final response = await SupabaseConfig.client
          .from('stylists_availability')
          .select(
            'id, stylists_Id, day_of_Week, start_time, end_time, isAvailable',
          )
          .eq('stylists_Id', stylistId)
          .eq('day_of_Week', dayOfWeek)
          .lte('start_time', time)
          .gte('end_time', time);

      return response.map(StylistsAvailabilityModel.fromJson).toList();
    } on PostgrestException catch (e) {
      throw Failures(message: e.message);
    } catch (e) {
      throw Failures(message: e.toString());
    }
  }
}
