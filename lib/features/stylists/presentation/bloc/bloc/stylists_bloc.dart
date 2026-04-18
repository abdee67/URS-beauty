import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urs_beauty/features/stylists/data/models/stylists_availability_model.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_availability_slot_entity.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylist_entity.dart';
import 'package:urs_beauty/features/stylists/domain/entities/stylists_availability_entity.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_nearby_stylists.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_stylist_by_service.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_stylist_detail.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_stylists.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_stylists_availability.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_stylists_availability_by_day.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_stylists_availability_by_time.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_stylists_service.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/search_stylists.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/update_stylists_availability.dart';

part 'stylists_event.dart';
part 'stylists_state.dart';

class StylistsBloc extends Bloc<StylistsEvent, StylistsState> {
  StylistsBloc(
    this.getStylistsAvailability,
    this.getStylistsAvailabilityByDay,
    this.getStylistsAvailabilityByTime,
    this.updateStylistsAvailability,
    this.getStylistsServices,
    this.getStylists,
    this.getStylistsByService,
    this.getStylistDetail,
    this.searchStylists,
    this.getNearByStylists,
  ) : super(const StylistsState()) {
    on<GetStylistsEvent>(_onGetStylists);
    on<GetStylistsByServiceEvent>(_onGetStylistsByService);
    on<GetStylistDetailEvent>(_onGetStylistDetail);
    on<SearchStylistsEvent>(_onSearchStylists);
    on<GetStylistsServicesEvent>(_onGetStylistsServices);
    on<GetNearbyStylistsEvent>(_onGetNearbyStylists);
    on<UpdateStylistsAvailabilityEvent>(_onUpdateStylistsAvailability);
    on<GetStylistsAvailabilityEvent>(_onGetStylistsAvailability);
    on<GetStylistsAvailabilityByDayEvent>(_onGetStylistsAvailabilityByDay);
    on<GetStylistsAvailabilityByTimeEvent>(_onGetStylistsAvailabilityByTime);
  }

  final GetStylistsAvailability getStylistsAvailability;
  final GetStylistsAvailabilityByDay getStylistsAvailabilityByDay;
  final GetStylistsAvailabilityByTime getStylistsAvailabilityByTime;
  final UpdateStylistsAvailability updateStylistsAvailability;
  final GetStylistsService getStylistsServices;
  final GetStylists getStylists;
  final GetStylistByService getStylistsByService;
  final GetStylistDetail getStylistDetail;
  final SearchStylists searchStylists;
  final GetNearbyStylists getNearByStylists;

  Future<void> _onGetStylists(
    GetStylistsEvent event,
    Emitter<StylistsState> emit,
  ) async {
    emit(state.stylistsLoading());
    final result = await getStylists();
    result.fold(
      (failure) =>
          emit(state.stylistsError("Can't get stylists: ${failure.message}")),
      (stylists) => emit(
        state.copyWith(
          stylists: stylists,
          status: StylistsStatus.stylisstsLoaded,
        ),
      ),
    );
  }

  Future<void> _onGetStylistsByService(
    GetStylistsByServiceEvent event,
    Emitter<StylistsState> emit,
  ) async {
    emit(state.stylistsByServiceLoading());
    final result = await getStylistsByService(event.serviceId);
    result.fold(
      (failure) => emit(
        state.stylistsError(
          "Can't get stylists by service: ${failure.message}",
        ),
      ),
      (stylists) => emit(
        state.copyWith(
          stylistsByService: stylists,
          status: StylistsStatus.stylistsByServiceLoaded,
        ),
      ),
    );
  }

  Future<void> _onGetStylistDetail(
    GetStylistDetailEvent event,
    Emitter<StylistsState> emit,
  ) async {
    emit(state.stylistDetailLoading());
    final result = await getStylistDetail(event.stylistId);
    result.fold(
      (failure) => emit(
        state.stylistsError("Can't get stylist detail: ${failure.message}"),
      ),
      (stylist) => emit(
        state.copyWith(
          stylistDetail: stylist,
          status: StylistsStatus.stylistDetailLoaded,
        ),
      ),
    );
  }

  Future<void> _onSearchStylists(
    SearchStylistsEvent event,
    Emitter<StylistsState> emit,
  ) async {
    emit(state.stylistSearching());
    final result = await searchStylists(event.query);
    result.fold(
      (failure) => emit(
        state.stylistsError("Can't get searched stylists: ${failure.message}"),
      ),
      (stylists) => emit(
        state.copyWith(
          searchedStylists: stylists,
          status: StylistsStatus.success,
        ),
      ),
    );
  }

  Future<void> _onGetStylistsServices(
    GetStylistsServicesEvent event,
    Emitter<StylistsState> emit,
  ) async {
    emit(state.stylistsServiceLoading());
    final result = await getStylistsServices(event.stylistId);
    result.fold(
      (failure) => emit(
        state.stylistsError("Can't get stylist services: ${failure.message}"),
      ),
      (services) => emit(
        state.copyWith(
          stylsitService: services,
          status: StylistsStatus.stylistsServiceLoaded,
        ),
      ),
    );
  }

  Future<void> _onGetNearbyStylists(
    GetNearbyStylistsEvent event,
    Emitter<StylistsState> emit,
  ) async {
    emit(state.nearbyStylistsLoading());
    final result = await getNearByStylists(
      event.latitude,
      event.longitude,
      event.radius,
    );
    result.fold(
      (failure) => emit(
        state.stylistsError("Can't get nearby stylists: ${failure.message}"),
      ),
      (stylists) => emit(
        state.copyWith(
          nearbyStylists: stylists,
          status: StylistsStatus.nearbyStylistsLoaded,
        ),
      ),
    );
  }

  Future<void> _onUpdateStylistsAvailability(
    UpdateStylistsAvailabilityEvent event,
    Emitter<StylistsState> emit,
  ) async {
    emit(state.updateStylistsAvailabilityLoading());
    final result = await updateStylistsAvailability(event.availability);
    result.fold(
      (failure) => emit(
        state.stylistsError(
          "Can't update stylist availability: ${failure.message}",
        ),
      ),
      (_) => emit(
        state.copyWith(
          message: 'Stylists availability updated successfully',
          status: StylistsStatus.updateStylistsAvailabilityLoaded,
        ),
      ),
    );
  }

  Future<void> _onGetStylistsAvailability(
    GetStylistsAvailabilityEvent event,
    Emitter<StylistsState> emit,
  ) async {
    emit(state.stylistsAvailabilityLoading());
    final result = await getStylistsAvailability(event.stylistId);
    result.fold(
      (failure) => emit(
        state.stylistsError(
          "Can't get stylist availability: ${failure.message}",
        ),
      ),
      (availability) => emit(
        state.copyWith(
          stylistsAvailability: availability,
          status: StylistsStatus.stylistsAvailabilityLoaded,
        ),
      ),
    );
  }

  Future<void> _onGetStylistsAvailabilityByDay(
    GetStylistsAvailabilityByDayEvent event,
    Emitter<StylistsState> emit,
  ) async {
    emit(state.stylistsAvailabilityByDayLoading());
    final result = await getStylistsAvailabilityByDay(
      event.stylistId,
      event.dayOfWeek,
    );
    result.fold(
      (failure) => emit(
        state.stylistsError(
          "Can't get stylist availability by day: ${failure.message}",
        ),
      ),
      (availability) => emit(
        state.copyWith(
          stylistsAvailabilityByDay: availability,
          status: StylistsStatus.stylistsAvailabilityByDayLoaded,
        ),
      ),
    );
  }

  Future<void> _onGetStylistsAvailabilityByTime(
    GetStylistsAvailabilityByTimeEvent event,
    Emitter<StylistsState> emit,
  ) async {
    emit(state.stylistsAvailabilityByTimeLoading());
    final result = await getStylistsAvailabilityByTime(
      event.stylistId,
      event.serviceId,
      event.selectedDate,
      ignoredBookingId: event.ignoredBookingId,
    );
    result.fold(
      (failure) => emit(
        state.stylistsError(
          "Can't get stylist availability by time: ${failure.message}",
        ),
        
      ),
      
      (availability) => emit(
        state.copyWith(
          stylistsAvailabilityByTime: availability,
          status: StylistsStatus.stylistsAvailabilityByTimeLoaded,
        ),
      ),
      
    );

  }
}
