import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/config/supabase_config.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/home/data/models/deal_model.dart';
import 'package:urs_beauty/features/home/data/models/professionals_model.dart';
import 'package:urs_beauty/features/home/data/models/service_categories_model.dart';

class HomeRemoteDataSource {
  Future<List<ServiceCategoriesModel>> getServices() async {
    try {
      final response = await SupabaseConfig.client
          .from('service_categories')
          .select('id,name,description,icon_url,is_active')
          .eq('is_active', true)
          .limit(5);
      return response.map(ServiceCategoriesModel.fromJson).toList();
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

  Future<List<DealModel>> getDeals() async {
    try {
      // First, let's try without any filters to see if data exists
      print('Attempting to query deals table...'); // Debug log

      final response = await SupabaseConfig.client
          .from('deals')
          .select('*')
          .limit(10);

      print('Deals query response: $response'); // Debug log
      print('Deals response length: ${response.length}'); // Debug log

      if (response.isNotEmpty) {
        print('First deal keys: ${response.first.keys}'); // Debug log
        print('First deal data: ${response.first}'); // Debug log
      } else {
        // Try to get count of records in the table
        try {
          final countResponse = await SupabaseConfig.client
              .from('deals')
              .select()
              .count();
          print('Total deals count in database: $countResponse'); // Debug log
        } catch (countError) {
          print('Error getting count: $countError'); // Debug log
        }
      }

      return response.map(DealModel.fromJson).toList();
    } on PostgrestException catch (e) {
      print('PostgrestException in getDeals: ${e.message}'); // Debug log
      print('PostgrestException details: ${e.details}'); // Debug log
      print('PostgrestException hint: ${e.hint}'); // Debug log
      throw Failures(message: e.message);
    } catch (e) {
      print('Exception in getDeals: ${e.toString()}'); // Debug log
      throw Failures(message: e.toString());
    }
  }
}
