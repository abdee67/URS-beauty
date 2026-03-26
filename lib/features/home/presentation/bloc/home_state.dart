part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoadSuccess extends HomeState {
  final List<Stylist> stylists;
  final List<Deal> deals;
  final List<ServiceCategories> services;

  const HomeLoadSuccess({
    required this.stylists,
    required this.deals,
    required this.services,
  });

  @override
  List<Object> get props => [stylists, deals, services];
}

class HomeLoadFailure extends HomeState {
  final String message;

  const HomeLoadFailure(this.message);

  @override
  List<Object> get props => [message];
}
