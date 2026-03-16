import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';
import 'package:urs_beauty/features/stylists/domain/repository/stylists_repository.dart';

class GetStylists {
  final StylistsRepository repository;

  GetStylists(this.repository,);

  Future<Either<Failures, List<Stylist>>> call() async {
    return await repository.getStylists();
  }
}