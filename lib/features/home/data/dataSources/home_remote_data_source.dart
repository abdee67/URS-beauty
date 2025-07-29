import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/config/supabase_config.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/home/data/models/deal_model.dart';
import 'package:urs_beauty/features/home/data/models/professionals_model.dart';
import 'package:urs_beauty/features/home/data/models/service_model.dart';

class HomeRemoteDataSource {
  Future<List<ServiceModel>> getServices() async {
    try {
      final response = await SupabaseConfig.client
          .from('service_categories')
          .select('id,name,description,icon_url')
          .eq('is_active', true)
          .limit(5);
      return response.map(ServiceModel.fromJson).toList();
    } on PostgrestException catch (e) {
      throw Failures(message: e.message);
    } catch (e) {
      throw Failures(message: e.toString());
    }
  }

  Future<List<ProfessionalModel>> getProfessionals() async {
    try {
      final response = await SupabaseConfig.client
          .from('professionals')
          .select('''
      id,
      buisness_name,
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
          .eq('is_active', true)
          .limit(5);

      return response.map(ProfessionalModel.fromJson).toList();
    } on PostgrestException catch (e) {
      throw Failures(message: e.message);
    } catch (e) {
      throw Failures(message: e.toString());
    }
  }

  Future<List<DealModel>> getDeals() async {
    try {
      final response = await SupabaseConfig.client
          .from('deals')
          .select(
            'id, title, description, original_price, discounted_price, service_name,service_category(name)',
          )
          .order('created_at', ascending: false);

      return response.map(DealModel.fromJson).toList();
    } on PostgrestException catch (e) {
      throw Failures(message: e.message);
    } catch (e) {
      throw Failures(message: e.toString());
    }
  }
}
