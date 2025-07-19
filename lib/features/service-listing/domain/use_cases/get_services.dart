import 'package:urs_beauty/features/service-listing/data/service_repo.dart';
import 'package:urs_beauty/features/service-listing/domain/models/service_model.dart';

class GetServices {
  final ServiceRepository _repository;

  GetServices(this._repository);

  Future<List<ServiceModel>> execute({
    String? categoryId,
    String? searchQuery,
    double? minRating,
    double? maxPrice,
    int? limit,
    int? offset,
  }) async {
    return await _repository.getServices(
      categoryId: categoryId,
      searchQuery: searchQuery,
      minRating: minRating,
      maxPrice: maxPrice,
      limit: limit,
      offset: offset,
    );
  }
}