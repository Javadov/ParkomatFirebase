// import 'package:bloc_test/bloc_test.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:parking_user/blocs/parking/parking_bloc.dart';
// import 'package:parking_user/blocs/parking/parking_event.dart';
// import 'package:parking_user/blocs/parking/parking_state.dart';
// import 'package:parking_shared/models/parking_space.dart';
// import 'package:parking_shared/models/parking.dart';

// import '../mocks/mock_repositories.dart';

// void main() {
//   late ParkingBloc parkingBloc;
//   late MockParkingRepository mockParkingRepository;

//   setUp(() {
//     mockParkingRepository = MockParkingRepository();
//     parkingBloc = ParkingBloc(parkingRepository: mockParkingRepository);
//   });

//   tearDown(() {
//     parkingBloc.close();
//   });

//   group('ParkingBloc', () {
//     group('LoadParkingSpaces', () {
//       final mockSpaces = [
//         ParkingSpace(
//           id: 1,
//           address: '123 Main St',
//           city: 'Sample City',
//           zipCode: '12345',
//           country: 'Sample Country',
//           latitude: 0.0,
//           longitude: 0.0,
//           pricePerHour: 10.0,
//         ),
//         ParkingSpace(
//           id: 2,
//           address: '456 Main St',
//           city: 'Sample City',
//           zipCode: '12345',
//           country: 'Sample Country',
//           latitude: 0.0,
//           longitude: 0.0,
//           pricePerHour: 10.0,
//         ),
//       ];

//       blocTest<ParkingBloc, ParkingState>(
//         'emits [ParkingLoading, ParkingSpacesLoaded] when LoadParkingSpaces is successful',
//         build: () {
//           when(() => mockParkingRepository.getAllParkingSpaces())
//               .thenAnswer((_) async => mockSpaces);
//           return parkingBloc;
//         },
//         act: (bloc) => bloc.add(LoadParkingSpaces()),
//         expect: () => [
//           ParkingLoading(),
//           ParkingSpacesLoaded(mockSpaces),
//         ],
//         verify: (_) {
//           verify(() => mockParkingRepository.getAllParkingSpaces()).called(1);
//         },
//       );

//       blocTest<ParkingBloc, ParkingState>(
//         'emits [ParkingLoading, ParkingError] when LoadParkingSpaces fails',
//         build: () {
//           when(() => mockParkingRepository.getAllParkingSpaces())
//               .thenThrow(Exception('Failed to load'));
//           return parkingBloc;
//         },
//         act: (bloc) => bloc.add(LoadParkingSpaces()),
//         expect: () => [
//           ParkingLoading(),
//           ParkingError('Failed to load parking spaces: Exception: Failed to load'),
//         ],
//         verify: (_) {
//           verify(() => mockParkingRepository.getAllParkingSpaces()).called(1);
//         },
//       );
//     });

//     group('SearchParkingSpaces', () {
//       final query = 'Space 1';
//       final mockSearchResult = [
//         ParkingSpace(
//           id: 1,
//           address: '123 Main St',
//           city: 'Sample City',
//           zipCode: '12345',
//           country: 'Sample Country',
//           latitude: 0.0,
//           longitude: 0.0,
//           pricePerHour: 10.0,
//         ),
//       ];

//       blocTest<ParkingBloc, ParkingState>(
//         'emits [ParkingLoading, ParkingSearchResult] when SearchParkingSpaces is successful',
//         build: () {
//           when(() => mockParkingRepository.searchParkingSpaces(query))
//               .thenAnswer((_) async => mockSearchResult);
//           return parkingBloc;
//         },
//         act: (bloc) => bloc.add(SearchParkingSpaces(query)),
//         expect: () => [
//           ParkingLoading(),
//           ParkingSearchResult(mockSearchResult),
//         ],
//         verify: (_) {
//           verify(() => mockParkingRepository.searchParkingSpaces(query)).called(1);
//         },
//       );

//       blocTest<ParkingBloc, ParkingState>(
//         'emits [ParkingLoading, ParkingError] when SearchParkingSpaces fails',
//         build: () {
//           when(() => mockParkingRepository.searchParkingSpaces(query))
//               .thenThrow(Exception('Search failed'));
//           return parkingBloc;
//         },
//         act: (bloc) => bloc.add(SearchParkingSpaces(query)),
//         expect: () => [
//           ParkingLoading(),
//           ParkingError('Failed to search parking spaces: Exception: Search failed'),
//         ],
//         verify: (_) {
//           verify(() => mockParkingRepository.searchParkingSpaces(query)).called(1);
//         },
//       );
//     });

//     group('StartParkingEvent', () {
//       final startEvent = StartParkingEvent(
//         userEmail: 'test@example.com',
//         registrationNumber: 'ABC123',
//         parkingSpaceId: 1,
//         startTime: DateTime.now(),
//         endTime: DateTime.now().add(Duration(hours: 1)),
//         totalCost: 20.0,
//       );

//       blocTest<ParkingBloc, ParkingState>(
//         'emits [ParkingOperationSuccess] when StartParkingEvent is successful',
//         build: () {
//           when(() => mockParkingRepository.startParking(
//                 userEmail: startEvent.userEmail,
//                 registrationNumber: startEvent.registrationNumber,
//                 parkingSpaceId: startEvent.parkingSpaceId,
//                 startTime: startEvent.startTime,
//                 endTime: startEvent.endTime,
//                 totalCost: startEvent.totalCost,
//               )).thenAnswer((_) async => true);
//           return parkingBloc;
//         },
//         act: (bloc) => bloc.add(startEvent),
//         expect: () => [
//           ParkingOperationSuccess(),
//         ],
//         verify: (_) {
//           verify(() => mockParkingRepository.startParking(
//                 userEmail: startEvent.userEmail,
//                 registrationNumber: startEvent.registrationNumber,
//                 parkingSpaceId: startEvent.parkingSpaceId,
//                 startTime: startEvent.startTime,
//                 endTime: startEvent.endTime,
//                 totalCost: startEvent.totalCost,
//               )).called(1);
//         },
//       );

//       blocTest<ParkingBloc, ParkingState>(
//         'emits [ParkingError] when StartParkingEvent fails',
//         build: () {
//           when(() => mockParkingRepository.startParking(
//                 userEmail: startEvent.userEmail,
//                 registrationNumber: startEvent.registrationNumber,
//                 parkingSpaceId: startEvent.parkingSpaceId,
//                 startTime: startEvent.startTime,
//                 endTime: startEvent.endTime,
//                 totalCost: startEvent.totalCost,
//               )).thenAnswer((_) async => false);
//           return parkingBloc;
//         },
//         act: (bloc) => bloc.add(startEvent),
//         expect: () => [
//           ParkingError('Failed to start parking'),
//         ],
//         verify: (_) {
//           verify(() => mockParkingRepository.startParking(
//                 userEmail: startEvent.userEmail,
//                 registrationNumber: startEvent.registrationNumber,
//                 parkingSpaceId: startEvent.parkingSpaceId,
//                 startTime: startEvent.startTime,
//                 endTime: startEvent.endTime,
//                 totalCost: startEvent.totalCost,
//               )).called(1);
//         },
//       );
//     });

//     group('LoadActiveParkings', () {
//       final mockActiveParkings = [
//         Parking(
//           parkingSpaceId: 1,
//           vehicleRegistrationNumber: 'ABC123',
//           startTime: DateTime.now(),
//           totalCost: 20.0,
//           userEmail: 'test@example.com',
//         ),
//       ];

//       blocTest<ParkingBloc, ParkingState>(
//         'emits [ParkingLoading, ActiveParkingsLoaded] when LoadActiveParkings is successful',
//         build: () {
//           when(() => mockParkingRepository.getActiveParkings(userEmail: 'test@example.com'))
//               .thenAnswer((_) async => mockActiveParkings);
//           return parkingBloc;
//         },
//         act: (bloc) => bloc.add(LoadActiveParkings('test@example.com')),
//         expect: () => [
//           ParkingLoading(),
//           ActiveParkingsLoaded(mockActiveParkings),
//         ],
//         verify: (_) {
//           verify(() => mockParkingRepository.getActiveParkings(userEmail: 'test@example.com'))
//               .called(1);
//         },
//       );

//       blocTest<ParkingBloc, ParkingState>(
//         'emits [ParkingLoading, ParkingError] when LoadActiveParkings fails',
//         build: () {
//           when(() => mockParkingRepository.getActiveParkings(userEmail: 'test@example.com'))
//               .thenThrow(Exception('Failed to load active parkings'));
//           return parkingBloc;
//         },
//         act: (bloc) => bloc.add(LoadActiveParkings('test@example.com')),
//         expect: () => [
//           ParkingLoading(),
//           ParkingError('Failed to load active parkings: Exception: Failed to load active parkings'),
//         ],
//         verify: (_) {
//           verify(() => mockParkingRepository.getActiveParkings(userEmail: 'test@example.com'))
//               .called(1);
//         },
//       );
//     });
//   });
// }