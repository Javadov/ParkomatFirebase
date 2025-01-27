import 'package:equatable/equatable.dart';
import 'package:parking_shared/models/parking_space.dart';

abstract class ParkingSpaceEvent extends Equatable {
  const ParkingSpaceEvent();

  @override
  List<Object?> get props => [];
}

class LoadParkingSpaces extends ParkingSpaceEvent {}

class AddParkingSpace extends ParkingSpaceEvent {
  final ParkingSpace parkingSpace;

  const AddParkingSpace(this.parkingSpace);

  @override
  List<Object?> get props => [parkingSpace];
}

class UpdateParkingSpace extends ParkingSpaceEvent {
  final ParkingSpace parkingSpace;

  const UpdateParkingSpace(this.parkingSpace);

  @override
  List<Object?> get props => [parkingSpace];
}

class DeleteParkingSpace extends ParkingSpaceEvent {
  final String id;

  const DeleteParkingSpace(this.id);

  @override
  List<Object?> get props => [id];
}