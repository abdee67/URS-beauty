 
  import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/config/supabase_config.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/professionals/data/datasources/professionals_remote_data_source.dart';
import 'package:urs_beauty/features/professionals/data/models/professionals_model.dart';

class ProfessionalsRemoteDataSourceImpl implements ProfessionalsRemoteDataSource {
  @override
 Future<List<ProfessionalModel>> getProfessionals() async {
    try {
      final response = await SupabaseConfig.client
          .from('professionals')
          .select('''
      id,
      business_name,
      description,
      service_radius_km,
      avg_rating,
      image_url,
      professionals_services (
        service_id,
        services (
          name,
          description
        )
      )
    ''')
          .eq('is_verified', true)
          .limit(5);

      return response.map(ProfessionalModel.fromJson).toList();
    } on PostgrestException catch (e) {
      throw Failures(message: e.message);
    } catch (e) {
      throw Failures(message: e.toString());
    }
  }
 }