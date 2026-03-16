import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/features/beauty_services/domain/usecases/get_service_by_professionals.dart';
import 'package:urs_beauty/features/beauty_services/domain/usecases/get_service_by_category.dart';
import 'package:urs_beauty/features/beauty_services/domain/usecases/get_service_detail.dart';
import 'package:urs_beauty/features/beauty_services/domain/usecases/get_services.dart';
import 'package:urs_beauty/features/beauty_services/domain/usecases/search_services.dart';
import 'package:urs_beauty/features/beauty_services/presentation/bloc/service_event.dart';
import 'package:urs_beauty/features/beauty_services/presentation/bloc/service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {

  final  GetServices getServices;
  final GetServiceByCategory getServiceByCategory;
  final GetServiceByProfessionals getServiceByProfessionals;
  final GetServiceDetail getServiceDetail;
  final SearchService searchServices;

   ServiceBloc({
    required this.getServices,
    required this.getServiceByCategory,
    required this.getServiceByProfessionals,
    required this.getServiceDetail,
    required this.searchServices,
   }) : super(const ServiceState()) {

    on<FetchServices>((event,emit) async {
      emit(state.serviceLoading());
      final result = await getServices();
      result.fold(
        (failure) => emit(state.serviceFailure(failure.message)),
        (services) => emit(state.copyWith(services: services, message: 'Service Loaded Successfully!' , status: ServiceStatus.serviceLoaded) ),
      );
    });
    on<FetchServiceByCategory>((event, emit) async{
      emit(state.serviceLoadingByCategory());
      final result = await getServiceByCategory(event.categoryId);
      result.fold(
        (failure) => emit(state.serviceFailure(failure.message)),
        (services) => emit(state.copyWith(servicesByCategory:services, status: ServiceStatus.serviceLoadedByCategory)),
      );
    });

    on<FetchServiceByProfessionals> ((event,emit) async{
      emit(state.serviceLoadingByProfesional());
      final result = await getServiceByProfessionals(event.professionalsId);
      result.fold(
        (failure) => emit(state.serviceFailure(failure.message)),
        (services) => emit(state.copyWith(servicesByProfessionals:services, status: ServiceStatus.serviceLoadedByProfessional)),
      );
    });
    on<FetchServiceDetail>((event,emit) async{
      emit(state.serviceDetailLoading());
      final result = await getServiceDetail(event.serviceId);
      result.fold(
        (failure) => emit(state.serviceFailure(failure.message)),
        (service) => emit(state.copyWith(serviceDetail:service, status: ServiceStatus.serviceDetailLoaded)),
      );
    });
    on<SearchServices>((event,emit) async{
      emit(state.searchedServiceLoading());
      final result = await searchServices(event.query);
      result.fold(
        (failure) => emit(state.serviceFailure(failure.message)),
        (services) => emit(state.copyWith(searchedServices:services, status: ServiceStatus.searchedServiceLoaded)),
      );
    });

    }
   }