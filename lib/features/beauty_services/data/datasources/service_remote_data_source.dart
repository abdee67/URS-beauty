
import 'package:urs_beauty/features/beauty_services/data/models/service_model.dart';

abstract class ServiceRemoteDataSource {
  Future<List<ServiceModel>> getServices();
  Future<List<ServiceModel>> getServiceByCategory(String categoryId);
  Future<List<ServiceModel>> getServiceByStylists(String stylistsId);
  Future<ServiceModel> getServiceDetail(String serviceId);
  Future<List<ServiceModel>> searchServices(String query);
}