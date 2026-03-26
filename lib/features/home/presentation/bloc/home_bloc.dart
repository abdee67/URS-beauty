import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/beauty_services/domain/usecases/get_service_categories.dart';
import 'package:urs_beauty/features/deals/domain/entities/deal.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';
import 'package:urs_beauty/features/beauty_services/domain/entities/service_category_entity.dart';
import 'package:urs_beauty/features/deals/domain/usescases/get_deals.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_stylists.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetStylists getStylists;
  final GetDeals getDeals;
  final GetServiceCategory getServices;
  HomeBloc({
    required this.getStylists,
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

    final Either<Failures, List<Stylist>> stylistsResult =
        await getStylists();
    final Either<Failures, List<ServiceCategories>> servicesResult =
        await getServices();
    final Either<Failures, List<Deal>> dealsResult = await getDeals();

    // Debug: Print results
    print('HomeBloc: Loading data...');
    stylistsResult.fold(
      (failure) => print('Stylist error: ${failure.message}'),
      (stylists) => print('Stylist loaded: ${stylists.length}'),
    );
    servicesResult.fold(
      (failure) => print('Services error: ${failure.message}'),
      (services) => print('Services loaded: ${services.length}'),
    );
    dealsResult.fold(
      (failure) => print('Deals error: ${failure.message}'),
      (deals) => print('Deals loaded: ${deals.length}'),
    );
    stylistsResult.fold(
      (failure) => emit(HomeLoadFailure(failure.message)),
      (stylists) {
        dealsResult.fold(
          (failure) => emit(HomeLoadFailure(failure.message)),
          (deals) => servicesResult.fold(
            (failure) => emit(HomeLoadFailure(failure.message)),
            (services) => emit(
              HomeLoadSuccess(
                stylists: stylists,
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
