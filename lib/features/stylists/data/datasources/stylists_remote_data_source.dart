import 'package:urs_beauty/features/stylists/data/models/stylists_model.dart';

abstract class StylistsRemoteDataSource {  

  Future <List<StylistModel>> getStylists();
}