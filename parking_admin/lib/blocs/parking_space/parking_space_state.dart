import 'package:equatable/equatable.dart';
import 'package:parking_shared/models/parking_space.dart';

abstract class ParkingSpaceState extends Equatable {
  const ParkingSpaceState();

  @override
  List<Object?> get props => [];
}

class ParkingSpaceInitial extends ParkingSpaceState {}

class ParkingSpaceLoading extends ParkingSpaceState {}

class ParkingSpaceLoaded extends ParkingSpaceState {
  final List<ParkingSpace> parkingSpaces;

  const ParkingSpaceLoaded(this.parkingSpaces);

  @override
  List<Object?> get props => [parkingSpaces];
}

class ParkingSpaceError extends ParkingSpaceState {
  final String error;

  const ParkingSpaceError(this.error);

  @override
  List<Object?> get props => [error];
}

class ParkingSpaceActionSuccess extends ParkingSpaceState {
  final String message;

  const ParkingSpaceActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}