    import 'package:urs_beauty/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';
abstract class StylistsRepository {
Future<Either<Failures, List<Stylist>>> getStylists();
}