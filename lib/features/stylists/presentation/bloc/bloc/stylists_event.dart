part of 'stylists_bloc.dart';

abstract class StylistsEvent extends Equatable {
  const StylistsEvent();

  @override
  List<Object> get props => [];
}

class GetStylistsEvent extends StylistsEvent {
  const GetStylistsEvent();
}

class SearchStylistsEvent extends StylistsEvent {
  const SearchStylistsEvent(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}

class GetStylistsByServiceEvent extends StylistsEvent {
  const GetStylistsByServiceEvent(this.serviceId);

  final String serviceId;

  @override
  List<Object> get props => [serviceId];
}

class GetStylistDetailEvent extends StylistsEvent {
  const GetStylistDetailEvent(this.stylistId);

  final String stylistId;

  @override
  List<Object> get props => [stylistId];
}

class GetNearbyStylistsEvent extends StylistsEvent {
  const GetNearbyStylistsEvent(this.latitude, this.longitude, this.radius);

  final double latitude;
  final double longitude;
  final double radius;

  @override
  List<Object> get props => [latitude, longitude, radius];
}

class GetStylistsAvailabilityEvent extends StylistsEvent {
  const GetStylistsAvailabilityEvent(this.stylistId);

  final String stylistId;

  @override
  List<Object> get props => [stylistId];
}

class UpdateStylistsAvailabilityEvent extends StylistsEvent {
  const UpdateStylistsAvailabilityEvent(this.availability);

  final StylistsAvailabilityModel availability;

  @override
  List<Object> get props => [availability];
}

class GetStylistsAvailabilityByDayEvent extends StylistsEvent {
  const GetStylistsAvailabilityByDayEvent(this.stylistId, this.dayOfWeek);

  final String stylistId;
  final String dayOfWeek;

  @override
  List<Object> get props => [stylistId, dayOfWeek];
}

class GetStylistsAvailabilityByTimeEvent extends StylistsEvent {
  const GetStylistsAvailabilityByTimeEvent(
    this.stylistId,
    this.serviceId,
    this.selectedDate,
  );

  final String stylistId;
  final String serviceId;
  final DateTime selectedDate;

  @override
  List<Object> get props => [stylistId, serviceId, selectedDate];
}

class GetStylistsServicesEvent extends StylistsEvent {
  const GetStylistsServicesEvent(this.stylistId);

  final String stylistId;

  @override
  List<Object> get props => [stylistId];
}
