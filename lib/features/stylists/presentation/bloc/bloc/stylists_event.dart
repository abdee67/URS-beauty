part of 'stylists_bloc.dart';

abstract class StylistsEvent extends Equatable {
  const StylistsEvent();

  @override
  List<Object> get props => [];
}

class GetStylistsEvent extends StylistsEvent {
  const GetStylistsEvent();

  @override
  List<Object> get props => [];
}

class SearchStylistsEvent extends StylistsEvent {
  final String query;
  const SearchStylistsEvent(this.query);
  @override
  List<Object> get props => [query];
}

class GetStylistsByServiceEvent extends StylistsEvent {
  final String serviceId;
  const GetStylistsByServiceEvent(this.serviceId);
  @override
  List<Object> get props => [serviceId];
}

class GetStylistDetailEvent extends StylistsEvent {
  final String stylistId;
  const GetStylistDetailEvent(this.stylistId);
  @override
  List<Object> get props => [stylistId];
}

class GetNearbyStylistsEvent extends StylistsEvent {
  final double latitude;
  final double longitude;
  final double radius;
  const GetNearbyStylistsEvent(this.latitude, this.longitude, this.radius);
  @override
  List<Object> get props => [latitude, longitude, radius];
}

class GetStylistsAvailabilityEvent extends StylistsEvent {
  final String stylistId;
  const GetStylistsAvailabilityEvent(this.stylistId);
  @override
  List<Object> get props => [stylistId];
}

class UpdateStylistsAvailabilityEvent extends StylistsEvent {
  final StylistsAvailabilityModel availability;
  const UpdateStylistsAvailabilityEvent(this.availability);
  @override
  List<Object> get props => [availability];
}

class GetStylistsAvailabilityByDayEvent extends StylistsEvent {
  final String stylistId;
  final String dayOfWeek;
  const GetStylistsAvailabilityByDayEvent(this.stylistId, this.dayOfWeek);
  @override
  List<Object> get props => [stylistId, dayOfWeek];
}

class GetStylistsAvailabilityByTimeEvent extends StylistsEvent {
  final String stylistId;
  final String dayOfWeek;
  final String time;
  const GetStylistsAvailabilityByTimeEvent(this.stylistId, this.dayOfWeek, this.time);
  @override
  List<Object> get props => [stylistId, dayOfWeek, time];
}

class GetStylistsServicesEvent extends StylistsEvent {
  final String stylistId;
  const GetStylistsServicesEvent(this.stylistId);
  @override
  List<Object> get props => [stylistId];
}


