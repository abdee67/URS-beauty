import 'package:urs_beauty/features/service-listing/domain/models/category_model.dart';
import 'package:urs_beauty/features/service-listing/domain/models/service_model.dart';

abstract class ServiceRepository {
  Future<List<ServiceModel>> getServices({
    String? categoryId,
    String? searchQuery,
    double? minRating,
    double? maxPrice,
    int? limit,
    int? offset,
  });
  
  Future<List<CategoryModel>> getCategories();
  Future<void> toggleFavorite(String serviceId);
}