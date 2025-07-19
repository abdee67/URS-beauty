import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/features/service-listing/domain/models/service_model.dart';
import 'package:urs_beauty/features/service-listing/domain/use_cases/get_categories.dart';
import 'package:urs_beauty/features/service-listing/domain/use_cases/get_services.dart';
import 'package:urs_beauty/features/service-listing/domain/use_cases/toggle_favorite.dart';
import 'package:urs_beauty/features/service-listing/presentation/cubit/service_list_state.dart';

class ServiceListCubit extends Cubit<ServiceListState> {
  final GetServices _getServices;
  final GetCategories _getCategories;
  final ToggleFavorite _toggleFavorite;

  ServiceListCubit({
    required GetServices getServices,
    required GetCategories getCategories,
    required ToggleFavorite toggleFavorite,
  })  : _getServices = getServices,
        _getCategories = getCategories,
        _toggleFavorite = toggleFavorite,
        super(ServiceListState.initial());

  Future<void> loadInitialData() async {
    emit(state.copyWith(status: ServiceListStatus.loading));
    try {
      final categories = await _getCategories.execute();
      final services = await _getServices.execute();
      emit(state.copyWith(
        status: ServiceListStatus.success,
        services: services,
        categories: categories,
        filteredServices: services,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ServiceListStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> toggleFavorite(String serviceId) async {
    try {
      await _toggleFavorite.execute(serviceId);
      final updatedServices = state.services.map((service) {
        if (service.id == serviceId) {
          return service.copyWith(isFavorite: !service.isFavorite);
        }
        return service;
      }).toList();
      
      emit(state.copyWith(
        services: updatedServices,
        filteredServices: _applyFilters(updatedServices),
      ));
    } catch (e) {
      // Handle error
    }
  }

 void filterServices({
  String? categoryId,
  String? searchQuery,
  double? minRating,
  double? maxPrice,
}) {
  emit(state.copyWith(
    selectedCategoryId: categoryId,
    searchQuery: searchQuery,
    minRating: minRating,
    maxPrice: maxPrice,
    filteredServices: _applyFilters(state.services),
  ));
}

List<ServiceModel> _applyFilters(List<ServiceModel> services) {
  return services.where((service) {
    final categoryMatch = state.selectedCategoryId == null || 
        service.category.id == state.selectedCategoryId;
    
    final searchMatch = state.searchQuery == null ||
        state.searchQuery!.isEmpty ||
        service.name.toLowerCase().contains(state.searchQuery!.toLowerCase()) ||
        service.description.toLowerCase().contains(state.searchQuery!.toLowerCase());
    
    final ratingMatch = state.minRating == null ||
        service.rating >= state.minRating!;
    
    final priceMatch = state.maxPrice == null ||
        service.price <= state.maxPrice!;
    
    return categoryMatch && searchMatch && ratingMatch && priceMatch;
  }).toList();
}
}