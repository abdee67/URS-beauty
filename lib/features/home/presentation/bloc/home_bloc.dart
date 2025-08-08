import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/home/domain/entities/deal.dart';
import 'package:urs_beauty/features/home/domain/entities/professioanls.dart';
import 'package:urs_beauty/features/home/domain/entities/services.dart';
import 'package:urs_beauty/features/home/domain/usecases/get_deals.dart';
import 'package:urs_beauty/features/home/domain/usecases/get_professionals.dart';
import 'package:urs_beauty/features/home/domain/usecases/get_services.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetProfessionals getProfessionals;
  final GetDeals getDeals;
  final GetServices getServices;
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
        await getProfessionals.call();
    final Either<Failures, List<ServiceCategories>> servicesResult =
        await getServices.call();
    final Either<Failures, List<Deal>> dealsResult = await getDeals.call();

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
