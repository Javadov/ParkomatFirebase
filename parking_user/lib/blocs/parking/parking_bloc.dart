import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/repositories/parking_repository.dart';
import 'parking_event.dart';
import 'parking_state.dart';

class ParkingBloc extends Bloc<ParkingEvent, ParkingState> {
  final ParkingRepository parkingRepository;

  ParkingBloc({required this.parkingRepository}) : super(ParkingInitial()) {
    on<LoadParkingSpaces>(_onLoadParkingSpaces);
    on<SearchParkingSpaces>(_onSearchParkingSpaces);
    on<StartParkingEvent>(_onStartParking);
    on<LoadActiveParkings>(_onLoadActiveParkings);
    on<LoadParkingHistory>(_onLoadParkingHistory);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onLoadParkingSpaces(
    LoadParkingSpaces event,
    Emitter<ParkingState> emit,
  ) async {
    emit(ParkingLoading());
    try {
      final spaces = await parkingRepository.getAllParkingSpaces();
      emit(ParkingSpacesLoaded(spaces));
    } catch (e) {
      emit(ParkingError('Failed to load parking spaces: $e'));
    }
  }

  Future<void> _onSearchParkingSpaces(
    SearchParkingSpaces event,
    Emitter<ParkingState> emit,
  ) async {
    emit(ParkingLoading());
    try {
      final spaces = await parkingRepository.searchParkingSpaces(event.query);
      emit(ParkingSearchResult(spaces));
    } catch (e) {
      emit(ParkingError('Failed to search parking spaces: $e'));
    }
  }

  Future<void> _onStartParking(
    StartParkingEvent event,
    Emitter<ParkingState> emit,
  ) async {
    try {
      final success = await parkingRepository.startParking(
        userEmail: event.userEmail,
        registrationNumber: event.registrationNumber,
        parkingSpaceId: event.parkingSpaceId,
        startTime: event.startTime,
        endTime: event.endTime,
        totalCost: event.totalCost,
      );

      if (success) {
        emit(ParkingOperationSuccess());
      } else {
        emit(ParkingError('Failed to start parking'));
      }
    } catch (e) {
      emit(ParkingError('Error starting parking: $e'));
    }
  }

  Future<void> _onLoadActiveParkings(
    LoadActiveParkings event,
    Emitter<ParkingState> emit,
  ) async {
    emit(ParkingLoading());
    try {
      final activeParkings = await parkingRepository.getActiveParkings(userEmail: event.userEmail);
      emit(ActiveParkingsLoaded(activeParkings));
    } catch (e) {
      emit(ParkingError('Failed to load active parkings: $e'));
    }
  }

  Future<void> _onLoadParkingHistory(
    LoadParkingHistory event,
    Emitter<ParkingState> emit,
  ) async {
    emit(ParkingLoading());
    try {
      final history = await parkingRepository.getParkingHistory(userEmail: event.userEmail);
      emit(ParkingHistoryLoaded(history));
    } catch (e) {
      emit(ParkingError('Failed to load parking history: $e'));
    }
  }


  void _onClearSearch(
    ClearSearch event,
    Emitter<ParkingState> emit,
  ) {
    if (state is ParkingLoaded) {
      final currentState = state as ParkingLoaded;
      emit(ParkingLoaded(markers: currentState.markers, filteredParkingSpaces: currentState.filteredParkingSpaces));
    }
  }
}