 
 import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/config/supabase_config.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/beauty_services/data/datasources/service_categories_remote_data_source.dart';
import 'package:urs_beauty/features/beauty_services/data/models/service_categories_model.dart';

class ServiceCategoriesRemoteDataSourceImpl implements ServiceCategoriesRemoteDataSource {

  @override
 Future<List<ServiceCategoriesModel>> getServiceCategories() async {
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
}