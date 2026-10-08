import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/config/supabase_config.dart';
import 'package:urs_beauty/core/errors/failures/service_failures.dart';
import 'package:urs_beauty/features/beauty_services/data/datasources/service_remote_data_source.dart';
import 'package:urs_beauty/features/beauty_services/data/models/service_model.dart';

class ServiceRemoteDataSourceImpl implements ServiceRemoteDataSource {
  ServiceRemoteDataSourceImpl({SupabaseClient? client})
    : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  static const String _serviceTable = 'services';
  static const String _serviceColumns =
      'id, name, description, category_id, duration_minutes, base_price, '
      'min_price, created_at, updated_at, icon_url, is_active';

  @override
  Future<List<ServiceModel>> getServices() {
    return serviceDataSourceOperation(() async {
      final response = await _client
          .from(_serviceTable)
          .select(_serviceColumns)
          .eq('is_active', true)
          .order('name');

      return _mapServiceList(response);
    });
  }

  @override
  Future<List<ServiceModel>> getServiceByCategory(String categoryId) {
    return serviceDataSourceOperation(() async {
      requireValue(categoryId, 'Category id is required');

      final response = await _client
          .from(_serviceTable)
          .select(_serviceColumns)
          .eq('is_active', true)
          .eq('category_id', categoryId)
          .order('name');

      return _mapServiceList(response);
    });
  }

  @override
  Future<ServiceModel> getServiceDetail(String serviceId) {
    return serviceDataSourceOperation(() async {
      requireValue(serviceId, 'Service id is required');

      final response = await _client
          .from(_serviceTable)
          .select(_serviceColumns)
          .eq('is_active', true)
          .eq('id', serviceId)
          .single();

      return _mapService(response);
    });
  }

  @override
  Future<List<ServiceModel>> getServiceByStylists(String stylistsId) {
    return serviceDataSourceOperation(() async {
      requireValue(stylistsId, 'Stylist id is required');

      final response = await _client
          .from(_serviceTable)
          .select(_serviceColumns)
          .eq('is_active', true)
          .eq('stylists_id', stylistsId)
          .order('name');

      return _mapServiceList(response);
    });
  }

  @override
  Future<List<ServiceModel>> searchServices(String query) {
    return serviceDataSourceOperation(() async {
      final normalizedQuery = query.trim();
      if (normalizedQuery.isEmpty) {
        return getServices();
      }

      final response = await _client
          .from(_serviceTable)
          .select(_serviceColumns)
          .or(
            'name.ilike.%$normalizedQuery%,description.ilike.%$normalizedQuery%',
          )
          .eq('is_active', true)
          .order('name')
          .limit(5);

      return _mapServiceList(response);
    });
  }

  List<ServiceModel> _mapServiceList(dynamic response) {
    return (response as List)
        .map(
          (item) =>
              ServiceModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  ServiceModel _mapService(dynamic response) {
    return ServiceModel.fromJson(Map<String, dynamic>.from(response as Map));
  }
}
