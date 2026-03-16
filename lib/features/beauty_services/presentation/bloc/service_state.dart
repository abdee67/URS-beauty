import 'package:equatable/equatable.dart';
import 'package:urs_beauty/features/beauty_services/domain/entities/service_entity.dart';

enum ServiceStatus {
  serviceInitial,
  serviceLoading,
  serviceLoaded,
  serviceLoadingByCategory,
  serviceLoadedByCategory,
  serviceLoadingByProfessioanl,
  serviceLoadedByProfessional,
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
  final List<ServiceEntity> servicesByProfessionals;
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
    this.servicesByProfessionals = const [],
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
      copyWith(status: ServiceStatus.serviceLoadingByProfessioanl);
  ServiceState serviceLoadedByProfesional() =>
      copyWith(status: ServiceStatus.serviceLoadedByProfessional);
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

  bool get isServiceLoading => status == ServiceStatus.serviceLoading;
  bool get isServiceLoaded => status == ServiceStatus.serviceLoaded;
  bool get isSearchedServiceLoaded =>
      status == ServiceStatus.searchedServiceLoaded;
  bool get isServiceDetailLoaded => status == ServiceStatus.serviceDetailLoaded;
  bool get isServiceByProfessionalsLoaded =>
      status == ServiceStatus.serviceLoadedByProfessional;
  bool get isServiceByCategoryLoaded =>
      status == ServiceStatus.serviceLoadedByCategory;
  bool get isFailure => status == ServiceStatus.serviceError;

  // --- CopyWith for immutability ---
  ServiceState copyWith({
    ServiceStatus? status,
    ServiceEntity? service,
    ServiceEntity? serviceDetail,
    List<ServiceEntity>? services,
    List<ServiceEntity>? servicesByCategory,
    List<ServiceEntity>? servicesByProfessionals,
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
      servicesByProfessionals:
          servicesByProfessionals ?? this.servicesByProfessionals,
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
    servicesByProfessionals,
    searchedServices,
    serviceDetail,
    message,
    query,
  ];
}
