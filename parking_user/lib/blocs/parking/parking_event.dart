import 'package:equatable/equatable.dart';

abstract class ParkingEvent extends Equatable {
  const ParkingEvent();

  @override
  List<Object> get props => [];
}

class LoadParkingSpaces extends ParkingEvent {}

class SearchParkingSpaces extends ParkingEvent {
  final String query;

  const SearchParkingSpaces(this.query);

  @override
  List<Object> get props => [query];
}

class ClearSearch extends ParkingEvent {}

class StartParkingEvent extends ParkingEvent {
  final String userEmail;
  final String registrationNumber;
  final String parkingSpaceId;
  final DateTime startTime;
  final DateTime endTime;
  final double totalCost;

  const StartParkingEvent({
    required this.userEmail,
    required this.registrationNumber,
    required this.parkingSpaceId,
    required this.startTime,
    required this.endTime,
    required this.totalCost,
  });

  @override
  List<Object> get props => [userEmail, registrationNumber, parkingSpaceId, startTime, endTime, totalCost];
}

class LoadActiveParkings extends ParkingEvent {
  final String userEmail;

  const LoadActiveParkings(this.userEmail);

  @override
  List<Object> get props => [userEmail];
}

class LoadParkingHistory extends ParkingEvent {
  final String userEmail;

  const LoadParkingHistory(this.userEmail);

  @override
  List<Object> get props => [userEmail];
}