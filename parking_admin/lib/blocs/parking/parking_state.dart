part of 'parking_bloc.dart';

abstract class ParkingState extends Equatable {
  const ParkingState();

  @override
  List<Object?> get props => [];
}

class ParkingInitial extends ParkingState {}

class ParkingLoading extends ParkingState {}

class ParkingLoaded extends ParkingState {
  final List<Parking> activeParkings;
  final List<Parking> historicalParkings;
  final List<Parking> filteredParkings;

  const ParkingLoaded({
    required this.activeParkings,
    required this.historicalParkings,
    required this.filteredParkings,
  });

  ParkingLoaded copyWith({
    List<Parking>? activeParkings,
    List<Parking>? historicalParkings,
    List<Parking>? filteredParkings,
  }) {
    return ParkingLoaded(
      activeParkings: activeParkings ?? this.activeParkings,
      historicalParkings: historicalParkings ?? this.historicalParkings,
      filteredParkings: filteredParkings ?? this.filteredParkings,
    );
  }

  @override
  List<Object?> get props => [activeParkings, historicalParkings, filteredParkings];
}

class ParkingError extends ParkingState {
  final String message;

  const ParkingError(this.message);

  @override
  List<Object?> get props => [message];
}