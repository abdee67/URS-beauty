
abstract class ServiceRemoteDataSource {
  Future<List<ServiceModel>> getServices();
  Future<List<ServiceModel>> getServiceByCategory();
  Future<ServiceModel> getServiceDetail();
}