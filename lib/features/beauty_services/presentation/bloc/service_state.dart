import 'package:equatable/equatable.dart';
import 'package:urs_beauty/features/beauty_services/domain/entities/service_entity.dart';

enum ServiceStatus {
  serviceInitial,
  serviceLoading,
  serviceLoaded,
  serviceLoadingByCategory,
  serviceLoadedByCategory,
  serviceLoadingBystylist,
  serviceLoadedByStylist,
  searchedServiceLoading,
  searchedServiceLoaded,
  serviceDetailLoading,
  serviceDetailLoaded,
  serviceError,
}

class ServiceState extends Equatable {
  final ServiceStatus status;
  final ServiceEntity? service;
  final List<ServiceEntity> services;
  final List<ServiceEntity> servicesByCategory;
  final List<ServiceEntity> servicesByStylists;
  final List<ServiceEntity> searchedServices;
  final ServiceEntity? serviceDetail;
  final String? message;
  final String? query;

  const ServiceState({
    this.status = ServiceStatus.serviceInitial,
    this.message,
    this.service,
    this.servicesByCategory = const [],
    this.searchedServices = const [],
    this.serviceDetail ,
    this.servicesByStylists = const [],
    this.query,
    this.services = const [],
  });

  //Helper methods for state transitions
  ServiceState serviceLoading() =>
      copyWith(status: ServiceStatus.serviceLoading);
  ServiceState serviceLoaded() => copyWith(status: ServiceStatus.serviceLoaded);
  ServiceState serviceLoadingByCategory() =>
      copyWith(status: ServiceStatus.serviceLoadingByCategory);
  ServiceState serviceLoadByCategory() =>
      copyWith(status: ServiceStatus.serviceLoadedByCategory);
  ServiceState serviceLoadingByProfesional() =>
      copyWith(status: ServiceStatus.serviceLoadingBystylist);
  ServiceState serviceLoadedByProfesional() =>
      copyWith(status: ServiceStatus.serviceLoadedByStylist);
  ServiceState serviceDetailLoading() =>
      copyWith(status: ServiceStatus.serviceDetailLoading);
  ServiceState serviceDetailLoaded() =>
      copyWith(status: ServiceStatus.serviceDetailLoaded);
  ServiceState searchedServiceLoading() =>
      copyWith(status: ServiceStatus.searchedServiceLoading);
  ServiceState searchedServiceLoaded() =>
      copyWith(status: ServiceStatus.searchedServiceLoaded);
  ServiceState serviceIntial() =>
      copyWith(status: ServiceStatus.serviceInitial);
  ServiceState serviceFailure(String error) =>
      copyWith(status: ServiceStatus.serviceError, message: error);

  ServiceState serviceByCategoryLoading() =>
      copyWith(status: ServiceStatus.serviceLoadingByCategory);
  ServiceState serviceByCategoryLoaded() =>
      copyWith(status: ServiceStatus.serviceLoadedByCategory);

  // --- CopyWith for immutability ---
  ServiceState copyWith({
    ServiceStatus? status,
    ServiceEntity? service,
    ServiceEntity? serviceDetail,
    List<ServiceEntity>? services,
    List<ServiceEntity>? servicesByCategory,
    List<ServiceEntity>? servicesByStylists,
    List<ServiceEntity>? searchedServices,
    String? query,
    String? message,
  }) {
    return ServiceState(
      status: status ?? this.status,
      service: service ?? this.service,
      services: services ?? this.services,
      servicesByCategory: servicesByCategory ?? this.servicesByCategory,
      serviceDetail: serviceDetail ?? this.serviceDetail,
      searchedServices: searchedServices ?? this.searchedServices,
      servicesByStylists:
          servicesByStylists ?? this.servicesByStylists,
      message: message ?? this.message,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [
    status,
    service,
    services,
    servicesByCategory,
    servicesByStylists,
    searchedServices,
    serviceDetail,
    message,
    query,
  ];
}
