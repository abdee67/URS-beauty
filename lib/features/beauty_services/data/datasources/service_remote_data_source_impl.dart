import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/config/supabase_config.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/beauty_services/data/datasources/service_remote_data_source.dart';
import 'package:urs_beauty/features/beauty_services/data/models/service_model.dart';

class ServieRemoteDataSourceImpl implements ServiceRemoteDataSource{
  @override
   Future<List<ServiceModel>> getServices() async {
    try {
      final response = await SupabaseConfig.client
          .from('service')
          .select('id,name,description,icon_url,is_active')
          .eq('is_active', true)
          //.limit(5)
          ;
      return response.map(ServiceModel.fromJson).toList();
    } on PostgrestException catch (e) {
      throw Failures(message: e.message);
    } catch (e) {
      throw Failures(message: e.toString());
    }
  }
  @override
  Future <List<ServiceModel>> getServiceByCategory( String categoryId) async{
    try{
      final response = await SupabaseConfig.client
          .from('service')
          .select('id, name, description,category_id, icon_url, is_active')
          .eq('is_active', true)
          .eq('category_id', categoryId);
            return response.map(ServiceModel.fromJson).toList();
          }
          on PostgrestException catch (e){
            throw Failures(message: e.message);
          } catch (e){
            throw Failures(message: e.toString());
          }
  }
  @override
  Future <ServiceModel> getServiceDetail(String serviceId) async{
    try{
      final response = await SupabaseConfig.client
          .from('service')
          .select('id, name, description, duration_minutes, min_price, base_price, stylists_id, icon_url, is_active')
          .eq('is_active', true)
          .eq('id', serviceId)
          .single();
            return ServiceModel.fromJson(response);
          }
          on PostgrestException catch (e){
            throw Failures(message: e.message);
          } catch (e){
            throw Failures(message: e.toString());
          }
  }
  @override
    Future <List<ServiceModel>> getServiceByStylists(String stylistsId) async{
    try{
      final response = await SupabaseConfig.client
          .from('service')
          .select('id, name, description,stylists_id, icon_url, is_active')
          .eq('is_active', true)
          .eq('stylists_id', stylistsId);
            return response.map(ServiceModel.fromJson).toList();
          }
          on PostgrestException catch (e){
            throw Failures(message: e.message);
          } catch (e){
            throw Failures(message: e.toString());
          }
  }
  @override
  Future<List<ServiceModel>> searchServices(String query) async {
    try {
      final response = await SupabaseConfig.client
          .from('service')
          .select('*')
          .or('name.ilike.%query%, description.ilike.%query%')//search by name, description, or other relevant fields
          .eq('is_active', true)
          .limit(5);
      if (response.isNotEmpty) {
        return response.map(ServiceModel.fromJson).toList();
      } else {
        throw Failures(message: 'No services found matching the search query');
      }
    } on PostgrestException catch (e) {
      throw Failures(message: e.message);
    } catch (e) {
      throw Failures(message: e.toString());
    }
  }

}