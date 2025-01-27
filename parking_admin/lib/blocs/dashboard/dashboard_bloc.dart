import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:parking_admin/repositories/parking_repository.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final ParkingRepository parkingRepository;

  DashboardBloc(this.parkingRepository) : super(DashboardInitial()) {
    on<LoadDashboardData>((event, emit) async {
      emit(DashboardLoading());

      try {
        final allParkings = await parkingRepository.getAllParkings();

        // Count active parkings
        final activeParkings = allParkings
            .where((p) => p.endTime == null || p.endTime!.isAfter(DateTime.now()))
            .toList();
        final activeParkingCount = activeParkings.length;

        // Calculate total income
        final totalIncome = allParkings.fold(0.0, (sum, p) => sum + (p.totalCost));

        // Group by parking space ID
        final parkingSpacesMap = <int, int>{};
        for (var parking in allParkings) {
          parkingSpacesMap[int.parse(parking.parkingSpaceId)] =
              (parkingSpacesMap[parking.parkingSpaceId] ?? 0) + 1;
        }

        // Sort by popularity
        final sortedParkingSpaces = parkingSpacesMap.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        // Total unique parking spaces
        final totalParkingSpaces = parkingSpacesMap.keys.length;

        emit(DashboardLoaded(
          activeParkingCount: activeParkingCount,
          totalIncome: totalIncome,
          popularParkingSpaces: sortedParkingSpaces,
          totalParkingSpaces: totalParkingSpaces,
        ));
      } catch (e) {
        emit(DashboardError('Failed to load dashboard data: $e'));
      }
    });
  }
}