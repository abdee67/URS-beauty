import 'package:urs_beauty/features/service-listing/domain/models/category_model.dart';
import 'package:urs_beauty/features/service-listing/domain/models/service_model.dart';

enum ServiceListStatus { initial, loading, success, error }

class ServiceListState {
  final ServiceListStatus status;
  final List<ServiceModel> services;
  final List<ServiceModel> filteredServices;
  final List<CategoryModel> categories;
  final String? errorMessage;
  final String? selectedCategoryId;
  final String? searchQuery;
  final double? minRating;
  final double? maxPrice;

  const ServiceListState({
    required this.status,
    required this.services,
    required this.filteredServices,
    required this.categories,
    this.errorMessage,
    this.selectedCategoryId,
    this.searchQuery,
    this.minRating,
    this.maxPrice,
  });

  factory ServiceListState.initial() => const ServiceListState(
        status: ServiceListStatus.initial,
        services: [],
        filteredServices: [],
        categories: [],
      );

  ServiceListState copyWith({
    ServiceListStatus? status,
    List<ServiceModel>? services,
    List<ServiceModel>? filteredServices,
    List<CategoryModel>? categories,
    String? errorMessage,
    String? selectedCategoryId,
    String? searchQuery,
    double? minRating,
    double? maxPrice,
  }) {
    return ServiceListState(
      status: status ?? this.status,
      services: services ?? this.services,
      filteredServices: filteredServices ?? this.filteredServices,
      categories: categories ?? this.categories,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      minRating: minRating ?? this.minRating,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }
}