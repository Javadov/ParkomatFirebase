// ignore_for_file: unused_local_variable

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:parking_admin/repositories/parking_repository.dart';
import 'package:parking_shared/models/parking.dart';

part 'parking_event.dart';
part 'parking_state.dart';

class ParkingBloc extends Bloc<ParkingEvent, ParkingState> {
  final ParkingRepository parkingRepository;

  ParkingBloc({required this.parkingRepository}) : super(ParkingInitial()) {
    on<LoadParkings>(_onLoadParkings);
    on<FilterParkings>(_onFilterParkings);
    on<SortParkings>(_onSortParkings);
    on<StopParking>(_onStopParking); 
  }

  Future<void> _onLoadParkings(
      LoadParkings event, Emitter<ParkingState> emit) async {
    emit(ParkingLoading());
    try {
      final parkings = await parkingRepository.getAllParkings();
      final activeParkings = parkings
          .where((p) => p.endTime == null || p.endTime!.isAfter(DateTime.now()))
          .toList();
      final historicalParkings = parkings
          .where((p) => p.endTime != null && p.endTime!.isBefore(DateTime.now()))
          .toList();
      emit(ParkingLoaded(
        activeParkings: activeParkings,
        historicalParkings: historicalParkings,
        filteredParkings: historicalParkings,
      ));
    } catch (e) {
      emit(ParkingError('Failed to load parkings: $e'));
    }
  }

  void _onFilterParkings(
      FilterParkings event, Emitter<ParkingState> emit) {
    if (state is ParkingLoaded) {
      final currentState = state as ParkingLoaded;
      final filteredParkings = currentState.historicalParkings.where((parking) {
        final query = event.query.toLowerCase();
        final matchesId = parking.parkingSpaceId.toString().contains(query);
        final matchesVehicle =
            (parking.vehicleRegistrationNumber ?? '').toLowerCase().contains(query);
        final matchesStartDate =
            _formatTime(parking.startTime).contains(query);
        final matchesEndDate =
            _formatTime(parking.endTime).contains(query);
        return matchesId || matchesVehicle || matchesStartDate || matchesEndDate;
      }).toList();
      emit(currentState.copyWith(filteredParkings: filteredParkings));
    }
  }

  void _onSortParkings(SortParkings event, Emitter<ParkingState> emit) {
    if (state is ParkingLoaded) {
      final currentState = state as ParkingLoaded;
      final sortedParkings = List<Parking>.from(currentState.filteredParkings);

      switch (event.sortOption) {
        case 'By ID':
          sortedParkings.sort((a, b) => a.parkingSpaceId.compareTo(b.parkingSpaceId));
          break;
        case 'By Vehicle':
          sortedParkings.sort((a, b) => (a.vehicleRegistrationNumber ?? '')
              .compareTo(b.vehicleRegistrationNumber ?? ''));
          break;
        case 'By Start Date':
          sortedParkings.sort((a, b) => a.startTime.compareTo(b.startTime));
          break;
        case 'By End Date':
          sortedParkings.sort((a, b) => b.startTime.compareTo(a.startTime));
          break;
      }

      emit(currentState.copyWith(filteredParkings: sortedParkings));
    }
  }

  Future<void> _onStopParking(
      StopParking event, Emitter<ParkingState> emit) async {
    if (state is ParkingLoaded) {
      final currentState = state as ParkingLoaded;
      try {
        await parkingRepository.stopParking(event.parkingId, event.endTime);
        add(LoadParkings()); // Reload parking data
      } catch (e) {
        emit(ParkingError('Failed to stop parking: $e'));
      }
    }
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    return '${time.year}-${time.month}-${time.day}';
  }
}