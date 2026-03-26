import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';
import 'package:urs_beauty/features/stylists/domain/repository/stylists_repository.dart';

class GetStylistDetail {
  final StylistsRepository repository;
  const GetStylistDetail(this.repository);

  Future<Either<Failures, Stylist>> call(String stylistId) async {
    return await repository.getStylistDetail(stylistId);
  }
}