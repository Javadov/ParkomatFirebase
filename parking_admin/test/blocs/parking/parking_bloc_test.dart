// import 'package:bloc_test/bloc_test.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:parking_admin/blocs/parking/parking_bloc.dart';
// import 'package:parking_admin/repositories/parking_repository.dart';
// import 'package:parking_shared/models/parking.dart';

// class MockParkingRepository extends Mock implements ParkingRepository {}

// void main() {
//   late ParkingBloc parkingBloc;
//   late MockParkingRepository mockParkingRepository;

//   setUp(() {
//     mockParkingRepository = MockParkingRepository();
//     parkingBloc = ParkingBloc(parkingRepository: mockParkingRepository);

//     registerFallbackValue(DateTime.now());
//     registerFallbackValue(const SortParkings('By ID'));
//     registerFallbackValue(StopParking(1, DateTime(2025, 1, 5)));
//   });

//   group('ParkingBloc', () {
//     final parking1 = Parking(
//       parkingSpaceId: 1,
//       vehicleRegistrationNumber: 'ABC123',
//       startTime: DateTime(2025, 1, 1),
//       endTime: null,
//       totalCost: 0.0,
//       userEmail: 'user1@example.com',
//     );
//     final parking2 = Parking(
//       parkingSpaceId: 2,
//       vehicleRegistrationNumber: 'XYZ789',
//       startTime: DateTime(2025, 1, 2),
//       endTime: DateTime(2025, 1, 3),
//       totalCost: 50.0,
//       userEmail: 'user2@example.com',
//     );
//     final allParkings = [parking1, parking2];

//     group('LoadParkings', () {
//       blocTest<ParkingBloc, ParkingState>(
//         'emits [ParkingLoading, ParkingLoaded] when loading succeeds',
//         build: () {
//           when(() => mockParkingRepository.getAllParkings())
//               .thenAnswer((_) async => allParkings);
//           return parkingBloc;
//         },
//         act: (bloc) => bloc.add(LoadParkings()),
//         expect: () => [
//           ParkingLoading(),
//           ParkingLoaded(
//             activeParkings: [parking1],
//             historicalParkings: [parking2],
//             filteredParkings: [parking2],
//           ),
//         ],
//       );

//       blocTest<ParkingBloc, ParkingState>(
//         'emits [ParkingLoading, ParkingError] when loading fails',
//         build: () {
//           when(() => mockParkingRepository.getAllParkings())
//               .thenThrow(Exception('Failed to fetch data'));
//           return parkingBloc;
//         },
//         act: (bloc) => bloc.add(LoadParkings()),
//         expect: () => [
//           ParkingLoading(),
//           ParkingError('Failed to load parkings: Exception: Failed to fetch data'),
//         ],
//       );
//     });

//     group('FilterParkings', () {
//       blocTest<ParkingBloc, ParkingState>(
//         'filters parkings based on query',
//         build: () {
//           return parkingBloc;
//         },
//         seed: () => ParkingLoaded(
//           activeParkings: [parking1],
//           historicalParkings: [parking2],
//           filteredParkings: [],
//         ),
//         act: (bloc) {
//           bloc.add(FilterParkings('XYZ'));
//         },
//         expect: () => [
//           ParkingLoaded(
//             activeParkings: [parking1],
//             historicalParkings: [parking2],
//             filteredParkings: [parking2],
//           ),
//         ],
//       );

//       blocTest<ParkingBloc, ParkingState>(
//         'emits [ParkingError] when filter fails',
//         build: () {
//           return parkingBloc;
//         },
//         seed: () => ParkingLoaded(
//           activeParkings: [parking1],
//           historicalParkings: [parking2],
//           filteredParkings: [],
//         ),
//         act: (bloc) => bloc.add(FilterParkings('')),
//         expect: () => [
//           ParkingLoaded(
//             activeParkings: [parking1],
//             historicalParkings: [parking2],
//             filteredParkings: [parking2],
//           ),
//         ],
//       );
//     });

//     group('SortParkings', () {
//       blocTest<ParkingBloc, ParkingState>(
//         'sorts parkings by ID',
//         build: () {
//           return parkingBloc;
//         },
//         seed: () => ParkingLoaded(
//           activeParkings: [],
//           historicalParkings: allParkings,
//           filteredParkings: allParkings,
//         ),
//         act: (bloc) => bloc.add(SortParkings('By ID')),
//         expect: () => [
//           ParkingLoaded(
//             activeParkings: [],
//             historicalParkings: allParkings,
//             filteredParkings: [parking1, parking2],
//           ),
//         ],
//       );
//     });

//     group('StopParking', () {
//       blocTest<ParkingBloc, ParkingState>(
//         'stops a parking and reloads the list',
//         build: () {
//           when(() => mockParkingRepository.getAllParkings())
//               .thenAnswer((_) async => allParkings);
//           when(() => mockParkingRepository.stopParking(1, any()))
//               .thenAnswer((_) async => true);
//           return parkingBloc;
//         },
//         act: (bloc) => bloc
//           ..add(LoadParkings())
//           ..add(StopParking(1, DateTime(2025, 1, 5))),
//         expect: () => [
//           ParkingLoading(),
//           ParkingLoaded(
//             activeParkings: [parking1],
//             historicalParkings: [parking2],
//             filteredParkings: [parking2],
//           ),
//           ParkingLoading(), // After stopping, it reloads
//           ParkingLoaded(
//             activeParkings: [parking1],
//             historicalParkings: [parking2],
//             filteredParkings: [parking2],
//           ),
//         ],
//       );

//       blocTest<ParkingBloc, ParkingState>(
//         'emits ParkingError if stopping fails',
//         build: () {
//           when(() => mockParkingRepository.stopParking(1, any()))
//               .thenThrow(Exception('Stop failed'));
//           return parkingBloc;
//         },
//         act: (bloc) => bloc.add(StopParking(1, DateTime(2025, 1, 5))),
//         expect: () => [
//           ParkingError('Failed to stop parking: Exception: Stop failed'),
//         ],
//       );
//     });
//   });
// }