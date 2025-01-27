part of 'dashboard_bloc.dart';

abstract class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final int activeParkingCount;
  final double totalIncome;
  final List<MapEntry<int, int>> popularParkingSpaces;
  final int totalParkingSpaces;

  DashboardLoaded({
    required this.activeParkingCount,
    required this.totalIncome,
    required this.popularParkingSpaces,
    required this.totalParkingSpaces,
  });

  @override
  List<Object?> get props => [
        activeParkingCount,
        totalIncome,
        popularParkingSpaces,
        totalParkingSpaces,
      ];
}

class DashboardError extends DashboardState {
  final String message;

  DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}