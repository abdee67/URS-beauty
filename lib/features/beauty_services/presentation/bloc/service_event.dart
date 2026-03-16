abstract class ServiceEvent {}

class FetchServices extends ServiceEvent {}

class FetchServiceByCategory extends ServiceEvent {
  final String categoryId;
  FetchServiceByCategory(this.categoryId);
}

class FetchServiceByProfessionals extends ServiceEvent {
  final String professionalsId;
  FetchServiceByProfessionals(this.professionalsId);
}

class FetchServiceDetail extends ServiceEvent {
  final String serviceId;
  FetchServiceDetail(this.serviceId);
}

class SearchServices extends ServiceEvent {
  final String query;
  SearchServices(this.query);
}

