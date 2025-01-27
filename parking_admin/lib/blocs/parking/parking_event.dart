part of 'parking_bloc.dart';

abstract class ParkingEvent extends Equatable {
  const ParkingEvent();

  @override
  List<Object?> get props => [];
}

class LoadParkings extends ParkingEvent {}

class StopParking extends ParkingEvent {
  final String parkingId;
  final DateTime endTime;

  const StopParking(this.parkingId, this.endTime);

  @override
  List<Object> get props => [parkingId, endTime];
}

class FilterParkings extends ParkingEvent {
  final String query;

  const FilterParkings(this.query);

  @override
  List<Object?> get props => [query];
}

class SortParkings extends ParkingEvent {
  final String sortOption;

  const SortParkings(this.sortOption);

  @override
  List<Object?> get props => [sortOption];
}