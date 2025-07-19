import 'package:urs_beauty/features/service-listing/data/service_repo.dart';
import 'package:urs_beauty/features/service-listing/domain/models/category_model.dart';

class GetCategories {
  final ServiceRepository _repository;

  GetCategories(this._repository);

  Future<List<CategoryModel>> execute() async {
    return await _repository.getCategories();
  }
}