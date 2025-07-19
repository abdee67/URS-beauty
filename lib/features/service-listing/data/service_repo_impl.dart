import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urs_beauty/features/service-listing/domain/models/service_model.dart';
import 'package:urs_beauty/features/service-listing/domain/models/category_model.dart';
import 'package:urs_beauty/features/service-listing/data/service_repo.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final SupabaseClient _supabase;

  ServiceRepositoryImpl(this._supabase);

@override
Future<List<ServiceModel>> getServices({
  String? categoryId,
  String? searchQuery,
  double? minRating,
  double? maxPrice,
  int? limit,
  int? offset,
}) async {
  // Create the initial query
  final baseQuery = _supabase
      .from('services')
      .select('''
        *, 
        service_categories!inner(*),
        provider_services!inner(price, is_available),
        favorites:service_favorites(user_id)
      ''');

  // Build the filtered query
  PostgrestFilterBuilder filteredQuery = baseQuery
      .eq('is_active', true)
      .eq('provider_services.is_available', true);

  if (categoryId != null) {
    filteredQuery = filteredQuery.eq('service_categories.id', categoryId);
  }

  if (searchQuery != null && searchQuery.isNotEmpty) {
    filteredQuery = filteredQuery.ilike('name', '%$searchQuery%');
  }

  if (minRating != null) {
    filteredQuery = filteredQuery.gte('avg_rating', minRating);
  }

  if (maxPrice != null) {
    filteredQuery = filteredQuery.lte('provider_services.price', maxPrice);
  }

  // Handle limit/offset separately
  if (limit != null || offset != null) {
    final paginatedQuery = filteredQuery as PostgrestTransformBuilder;
    if (limit != null) paginatedQuery.limit(limit);
    if (offset != null) paginatedQuery.range(offset, (offset + (limit ?? 10) - 1));
    final response = await paginatedQuery;
    final data = response as List<dynamic>;
    return data.map((json) => ServiceModel.fromJson(json)).toList();
  }

  // Execute without pagination
  final response = await filteredQuery;
  final data = response as List<dynamic>;
  return data.map((json) => ServiceModel.fromJson(json)).toList();
}

  @override
  Future<List<CategoryModel>> getCategories() async {
    final data = await _supabase
        .from('service_categories')
        .select('*')
        .eq('is_active', true)
        .order('sort_order');
    
    return data.map((json) => CategoryModel.fromJson(json)).toList();
  }

  @override
  Future<void> toggleFavorite(String serviceId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final existing = await _supabase
        .from('service_favorites')
        .select()
        .eq('service_id', serviceId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) {
      await _supabase
          .from('service_favorites')
          .delete()
          .eq('service_id', serviceId)
          .eq('user_id', userId);
    } else {
      await _supabase
          .from('service_favorites')
          .insert({'service_id': serviceId, 'user_id': userId});
    }
  }
}