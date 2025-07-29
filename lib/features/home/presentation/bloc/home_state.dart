part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoadSuccess extends HomeState {
  final List<Professionals> professionals;
  final List<Deal> deals;
  final List<Services> services;

  const HomeLoadSuccess({
    required this.professionals,
    required this.deals,
    required this.services,
  });

  @override
  List<Object> get props => [professionals, deals, services];
}

class HomeLoadFailure extends HomeState {
  final String message;

  const HomeLoadFailure(this.message);

  @override
  List<Object> get props => [message];
}