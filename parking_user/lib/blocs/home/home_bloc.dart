import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parking_shared/models/parking_space.dart';
import 'package:parking_user/blocs/home/home_state.dart';
import 'package:parking_user/repositories/parking_repository.dart';

part 'home_event.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ParkingRepository parkingRepository;

  HomeBloc({required this.parkingRepository}) : super(HomeInitial()) {
    on<LoadParkingSpaces>(_onLoadParkingSpaces);
    on<SearchParkingSpaces>(_onSearchParkingSpaces);
    on<UpdateMapController>(_onUpdateMapController);
    on<SelectParkingSpace>(_onSelectParkingSpace);
  }

  void _onLoadParkingSpaces(
    LoadParkingSpaces event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final parkingSpaces = await parkingRepository.getAllParkingSpaces();
      final markers = parkingSpaces.map((space) {
        return Marker(
          markerId: MarkerId(space.id.toString()),
          position: LatLng(space.latitude, space.longitude),
          onTap: () {
            add(SelectParkingSpace(space));
          },
        );
      }).toSet();
      emit(HomeLoaded(markers: markers));
    } catch (e) {
      emit(HomeError('Failed to load parking spaces: $e'));
    }
  }

  void _onSearchParkingSpaces(
    SearchParkingSpaces event,
    Emitter<HomeState> emit,
  ) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final filteredMarkers = currentState.markers.where((marker) {
        return marker.markerId.value.contains(event.query);
      }).toSet();
      emit(currentState.copyWith(markers: filteredMarkers));
    }
  }

  void _onUpdateMapController(
    UpdateMapController event,
    Emitter<HomeState> emit,
  ) {
    // Optional: Handle map controller updates
  }

  void _onSelectParkingSpace(
    SelectParkingSpace event,
    Emitter<HomeState> emit,
  ) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(selectedParkingSpace: event.parkingSpace));
    }
  }
}