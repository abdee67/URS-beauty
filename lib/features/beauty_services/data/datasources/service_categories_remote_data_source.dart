import 'package:urs_beauty/features/beauty_services/data/models/service_categories_model.dart';

abstract class ServiceCategoriesRemoteDataSource {

  Future<List<ServiceCategoriesModel>> getServiceCategories();
  }