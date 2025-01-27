import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parking_shared/models/parking.dart';
import 'package:parking_shared/models/parking_space.dart';

abstract class ParkingState extends Equatable {
  const ParkingState();

  @override
  List<Object> get props => [];
}

class ParkingInitial extends ParkingState {}

class ParkingLoading extends ParkingState {}

class ParkingSpacesLoaded extends ParkingState {
  final List<ParkingSpace> parkingSpaces;

  const ParkingSpacesLoaded(this.parkingSpaces);

  @override
  List<Object> get props => [parkingSpaces];
}

class ParkingSearchResult extends ParkingState {
  final List<ParkingSpace> filteredSpaces;

  const ParkingSearchResult(this.filteredSpaces);

  @override
  List<Object> get props => [filteredSpaces];
}

class ParkingLoaded extends ParkingState {
  final Set<Marker> markers;
  final List<ParkingSpace> filteredParkingSpaces;

  ParkingLoaded({required this.markers, required this.filteredParkingSpaces});
}

class ActiveParkingsLoaded extends ParkingState {
  final List<Parking> activeParkings;

  const ActiveParkingsLoaded(this.activeParkings);

  @override
  List<Object> get props => [activeParkings];
}

class ParkingHistoryLoaded extends ParkingState {
  final List<Parking> parkingHistory;

  const ParkingHistoryLoaded(this.parkingHistory);

  @override
  List<Object> get props => [parkingHistory];
}

class ParkingOperationSuccess extends ParkingState {}

class ParkingError extends ParkingState {
  final String error;

  const ParkingError(this.error);

  @override
  List<Object> get props => [error];
}