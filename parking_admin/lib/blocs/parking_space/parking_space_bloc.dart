import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:parking_admin/repositories/parking_space_repository.dart';

import 'parking_space_event.dart';
import 'parking_space_state.dart';

class ParkingSpaceBloc extends Bloc<ParkingSpaceEvent, ParkingSpaceState> {
  final ParkingSpaceRepository repository;

  ParkingSpaceBloc(this.repository) : super(ParkingSpaceInitial()) {
    on<LoadParkingSpaces>(_onLoadParkingSpaces);
    on<AddParkingSpace>(_onAddParkingSpace);
    on<UpdateParkingSpace>(_onUpdateParkingSpace);
    on<DeleteParkingSpace>(_onDeleteParkingSpace);
  }

  Future<void> _onLoadParkingSpaces(
      LoadParkingSpaces event, Emitter<ParkingSpaceState> emit) async {
    emit(ParkingSpaceLoading());
    try {
      final parkingSpaces = await repository.getAllParkingSpaces();
      emit(ParkingSpaceLoaded(parkingSpaces));
    } catch (e) {
      emit(ParkingSpaceError('Failed to load parking spaces: $e'));
    }
  }

  Future<void> _onAddParkingSpace(
      AddParkingSpace event, Emitter<ParkingSpaceState> emit) async {
    try {
      await repository.addParkingSpace(event.parkingSpace);
      add(LoadParkingSpaces()); // Refresh the list
    } catch (e) {
      emit(ParkingSpaceError('Failed to add parking space: $e'));
    }
  }

  Future<void> _onUpdateParkingSpace(
      UpdateParkingSpace event, Emitter<ParkingSpaceState> emit) async {
    try {
      await repository.updateParkingSpace(event.parkingSpace);
      add(LoadParkingSpaces()); // Refresh the list
    } catch (e) {
      emit(ParkingSpaceError('Failed to update parking space: $e'));
    }
  }

  Future<void> _onDeleteParkingSpace(
      DeleteParkingSpace event, Emitter<ParkingSpaceState> emit) async {
    try {
      await repository.deleteParkingSpace(event.id);
      add(LoadParkingSpaces()); // Refresh the list
    } catch (e) {
      emit(ParkingSpaceError('Failed to delete parking space: $e'));
    }
  }
}