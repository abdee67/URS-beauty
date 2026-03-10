import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/professionals/data/models/professionals_model.dart';

abstract class ProfessionalsRemoteDataSource {

  Future <List<ProfessionalModel>> getProfessionals();
}