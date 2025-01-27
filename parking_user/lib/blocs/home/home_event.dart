part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadParkingSpaces extends HomeEvent {}

class SearchParkingSpaces extends HomeEvent {
  final String query;

  const SearchParkingSpaces(this.query);

  @override
  List<Object?> get props => [query];
}

class UpdateMapController extends HomeEvent {
  final GoogleMapController mapController;

  const UpdateMapController(this.mapController);

  @override
  List<Object?> get props => [mapController];
}

class SelectParkingSpace extends HomeEvent {
  final ParkingSpace parkingSpace;

  const SelectParkingSpace(this.parkingSpace);

  @override
  List<Object?> get props => [parkingSpace];
}