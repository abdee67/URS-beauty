 
 import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/config/supabase_config.dart';
import 'package:urs_beauty/core/errors/failures.dart' show Failures;
import 'package:urs_beauty/features/deals/data/datasource/deals_remote_data_source.dart';
import 'package:urs_beauty/features/deals/data/model/deal_model.dart';

class DealsRemoteDataSourceImpl implements DealsRemoteDataSource {

  @override
  Future<List<DealModel>> getDeals() async {
    try {
      // First, let's try without any filters to see if data exists
      print('Attempting to query deals table...'); // Debug log

      final response = await SupabaseConfig.client
          .from('deals')
          .select(
            '''id,title,description,original_price,discounted_price,image_url, service_categories(
          id,
          name,
          description
        )
        ''',
          )
          
          .limit(5);

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