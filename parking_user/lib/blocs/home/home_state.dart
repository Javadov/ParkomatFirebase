import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parking_shared/models/parking_space.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final Set<Marker> markers;
  final ParkingSpace? selectedParkingSpace;

  const HomeLoaded({required this.markers, this.selectedParkingSpace});

  HomeLoaded copyWith({
    Set<Marker>? markers,
    ParkingSpace? selectedParkingSpace,
  }) {
    return HomeLoaded(
      markers: markers ?? this.markers,
      selectedParkingSpace: selectedParkingSpace,
    );
  }

  @override
  List<Object?> get props => [markers, selectedParkingSpace];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}