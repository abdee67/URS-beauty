import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:urs_beauty/features/stylists/data/models/stylists_availability_model.dart';
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
  
  StylistsBloc(this.getStylistsAvailability, this.getStylistsAvailabilityByDay,
      this.getStylistsAvailabilityByTime,
      this.updateStylistsAvailability,
      this.getStylistsServices,
      this.getStylists,
      this.getStylistsByService,
      this.getStylistDetail,
      this.searchStylists,
      this.getNearByStylists
  )
  
   : super(StylistsState()) {
    on<GetStylistsEvent>((event, emit) async {
      emit(state.stylistsLoading());
      final result = await getStylists();
      result.fold(
        (failure) => emit(state.stylistsError('Çant get stylsits: ${failure.message}')),
       (stylists) => emit(state.copyWith(stylists: stylists, status: StylistsStatus.stylisstsLoaded)));
    });

    on<GetStylistsByServiceEvent>((event, emit) async {
      emit(state.stylistsByServiceLoading());
      final result = await getStylistsByService(event.serviceId);
      result.fold(
        (failure) => emit(state.stylistsError('Çant get stylsits by service: ${failure.message}')),
       (stylists) => emit(state.copyWith(stylistsByService: stylists, status: StylistsStatus.stylistsByServiceLoaded)));
    });

    on<GetStylistDetailEvent>((event, emit) async {
      emit(state.stylistDetailLoading());
      final result = await getStylistDetail(event.stylistId);
      result.fold(
        (failure) => emit(state.stylistsError('Çant get stylist detail: ${failure.message}')),
       (stylist) => emit(state.copyWith(stylistDetail: stylist, status: StylistsStatus.stylistDetailLoaded)));
    });

    on<SearchStylistsEvent>((event, emit) async {
      emit(state.stylistSearching());
      final result = await searchStylists(event.query);
      result.fold(
        (failure) => emit(state.stylistsError('Çant get searched stylsits: ${failure.message}')),
       (stylists) => emit(state.copyWith(searchedStylists: stylists, status: StylistsStatus.success)));
    });

    on<GetStylistsServicesEvent>((event, emit) async {
      emit(state.stylistsServiceLoading());
      final result = await getStylistsServices(event.stylistId);
      result.fold(
        (failure) => emit(state.stylistsError('Çant get stylsits services: ${failure.message}')),
       (services) => emit(state.copyWith(stylsitService: services, status: StylistsStatus.stylistsServiceLoaded)));
    });

      on<GetNearbyStylistsEvent>((event, emit) async {
        emit(state.nearbyStylistsLoading());
        final result = await getNearByStylists(event.latitude, event.longitude, event.radius);
        result.fold(
          (failure) => emit(state.stylistsError('Çant get nearby stylsits: ${failure.message}')),
        (stylists) => emit(state.copyWith(nearbyStylists: stylists, status: StylistsStatus.nearbyStylistsLoaded)));
      });

      on<UpdateStylistsAvailabilityEvent>((event, emit) async {
        emit(state.updateStylistsAvailabilityLoading());
        final result = await updateStylistsAvailability(event.availability);
        result.fold(
          (failure) => emit(state.stylistsError('Çant update stylsits availability: ${failure.message}')),
        (success) => emit(state.copyWith(message: 'Stylists availability updated successfully', status: StylistsStatus.updateStylistsAvailabilityLoaded)));
      });

      on<GetStylistsAvailabilityEvent>((event, emit) async {
        emit(state.stylistsAvailabilityLoading());
        final result = await getStylistsAvailability(event.stylistId);
        result.fold(
          (failure) => emit(state.stylistsError('Çant get stylsits availability: ${failure.message}')),
        (availability) => emit(state.copyWith(stylistsAvailability: availability, status: StylistsStatus.stylistsAvailabilityLoaded)));
      });

      on<GetStylistsAvailabilityByDayEvent>((event, emit) async {
        emit(state.stylistsAvailabilityByDayLoading());
        final result = await getStylistsAvailabilityByDay(event.stylistId, event.dayOfWeek);
        result.fold(
          (failure) => emit(state.stylistsError('Çant get stylsits availability by day: ${failure.message}')),
        (availability) => emit(state.copyWith(stylistsAvailabilityByDay: availability, status: StylistsStatus.stylistsAvailabilityByDayLoaded)));
      });

      on<GetStylistsAvailabilityByTimeEvent>((event, emit) async {
        emit(state.stylistsAvailabilityByTimeLoading());
        final result = await getStylistsAvailabilityByTime(event.stylistId, event.dayOfWeek, event.time);
        result.fold(
          (failure) => emit(state.stylistsError('Çant get stylsits availability by time: ${failure.message}')),
        (availability) => emit(state.copyWith(stylistsAvailabilityByTime: availability, status: StylistsStatus.stylistsAvailabilityByTimeLoaded)));
      });
  }
}
