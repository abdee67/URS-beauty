import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';
import 'package:urs_beauty/features/stylists/domain/repository/stylists_repository.dart';

class SearchStylists {
  final StylistsRepository repository;
  const SearchStylists(this.repository);

  Future<Either<Failures, List<Stylist>>> call(String query) async {
    return await repository.searchStylists(query);
  }
}