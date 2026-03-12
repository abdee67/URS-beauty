import 'package:urs_beauty/features/professionals/data/models/professionals_model.dart';

abstract class ProfessionalsRemoteDataSource {  

  Future <List<ProfessionalModel>> getProfessionals();
}