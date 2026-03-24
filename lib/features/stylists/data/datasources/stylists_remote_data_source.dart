import 'package:urs_beauty/features/stylists/data/models/stylists_availability_model.dart';
import 'package:urs_beauty/features/stylists/data/models/stylists_model.dart';
import 'package:urs_beauty/features/stylists/data/models/stylists_service_model.dart';

abstract class StylistsRemoteDataSource {  

  Future <List<StylistModel>> getStylists();
  Future<List<StylistModel>> getStylistsByService(String serviceId);
  Future<StylistModel> getStylistDetail(String stylistId);
  Future<List<StylistModel>> searchStylists(String query);  
  Future<List<StylistsServiceModel>> getStylistsServices(String stylistId);
  Future<List<StylistModel>> getNearByStylists(double latitude, double longitude, double radius);
  Future<void> updateStylistsAvailability(StylistsAvailabilityModel availability);
  Future<List<StylistsAvailabilityModel>> getStylistsAvailability(String stylistId);
  Future<List<StylistsAvailabilityModel>> getStylistsAvailabilityByDay(String stylistId, String dayOfWeek);
  Future<List<StylistsAvailabilityModel>> getStylistsAvailabilityByTime(String stylistId, String dayOfWeek, String time);
}