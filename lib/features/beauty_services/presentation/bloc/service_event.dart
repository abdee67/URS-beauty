abstract class ServiceEvent {}

class FetchServices extends ServiceEvent {}

class FetchServiceByCategory extends ServiceEvent {
  final String categoryId;
  FetchServiceByCategory(this.categoryId);
}

class FetchServiceByStylists extends ServiceEvent {
  final String stylistsId;
  FetchServiceByStylists(this.stylistsId);
}

class FetchServiceDetail extends ServiceEvent {
  final String serviceId;
  FetchServiceDetail(this.serviceId);
}

class SearchServices extends ServiceEvent {
  final String query;
  SearchServices(this.query);
}

