import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/beauty_services/domain/usecases/get_service_categories.dart';
import 'package:urs_beauty/features/deals/domain/entities/deal.dart';
import 'package:urs_beauty/features/professionals/domain/entities/professioanls.dart';
import 'package:urs_beauty/features/beauty_services/domain/entities/service_category_entity.dart';
import 'package:urs_beauty/features/deals/domain/usescases/get_deals.dart';
import 'package:urs_beauty/features/professionals/domain/usecases/get_professionals.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetProfessionals getProfessionals;
  final GetDeals getDeals;
  final GetServiceCategory getServices;
  HomeBloc({
    required this.getProfessionals,
    required this.getDeals,
    required this.getServices,
  }) : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    final Either<Failures, List<Professionals>> professionalsResult =
        await getProfessionals();
    final Either<Failures, List<ServiceCategories>> servicesResult =
        await getServices();
    final Either<Failures, List<Deal>> dealsResult = await getDeals();

    // Debug: Print results
    print('HomeBloc: Loading data...');
    professionalsResult.fold(
      (failure) => print('Professionals error: ${failure.message}'),
      (professionals) => print('Professionals loaded: ${professionals.length}'),
    );
    servicesResult.fold(
      (failure) => print('Services error: ${failure.message}'),
      (services) => print('Services loaded: ${services.length}'),
    );
    dealsResult.fold(
      (failure) => print('Deals error: ${failure.message}'),
      (deals) => print('Deals loaded: ${deals.length}'),
    );
    professionalsResult.fold(
      (failure) => emit(HomeLoadFailure(failure.message)),
      (professionals) {
        dealsResult.fold(
          (failure) => emit(HomeLoadFailure(failure.message)),
          (deals) => servicesResult.fold(
            (failure) => emit(HomeLoadFailure(failure.message)),
            (services) => emit(
              HomeLoadSuccess(
                professionals: professionals,
                deals: deals,
                services: services,
              ),
            ),
          ),
        );
      },
    );
  }
}
