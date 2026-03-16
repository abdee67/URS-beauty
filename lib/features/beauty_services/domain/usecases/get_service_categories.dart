import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/beauty_services/domain/entities/service_category_entity.dart';
import 'package:urs_beauty/features/beauty_services/domain/repositories/service_categories_repository.dart';

class GetServiceCategory{
  final ServiceCategoriesRepository repository;

  GetServiceCategory(this.repository);


  Future<Either<Failures, List<ServiceCategories>>> call(){
    return repository.getServiceCategories();
  }
}