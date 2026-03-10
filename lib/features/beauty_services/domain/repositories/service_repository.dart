  import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/beauty_services/domain/entities/service_category_entity.dart';

abstract class ServiceRepository {

Future<Either<Failures, List<ServiceCategories>>> getServices();
}