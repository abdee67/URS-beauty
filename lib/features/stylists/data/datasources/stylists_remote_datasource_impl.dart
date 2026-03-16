 
  import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/config/supabase_config.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/stylists/data/datasources/stylists_remote_data_source.dart';
import 'package:urs_beauty/features/stylists/data/models/stylists_model.dart';

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
 }