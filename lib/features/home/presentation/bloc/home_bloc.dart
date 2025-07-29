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

    final Either<Failures, List<Professionals>> professionalsResult =await getProfessionals();
    final Either<Failures, List<Services>> servicesResult = await getServices();
      final Either<Failures, List<Deal>> dealsResult = await getDeals();
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
