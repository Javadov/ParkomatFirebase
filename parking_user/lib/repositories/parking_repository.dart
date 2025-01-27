import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parking_shared/models/parking.dart';
import 'package:parking_shared/models/parking_space.dart';

class ParkingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hämta alla parkeringsplatser
  Future<List<ParkingSpace>> getAllParkingSpaces() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('parking_spaces').get();
      return snapshot.docs.map((doc) => ParkingSpace.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to fetch parking spaces: $e');
    }
  }

  // Sök efter parkeringsplatser
  Future<List<ParkingSpace>> searchParkingSpaces(String query) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('parking_spaces')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();
      return snapshot.docs.map((doc) => ParkingSpace.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Error searching parking spaces: $e');
    }
  }

  // Hämta användarens fordon
  Future<List<Map<String, dynamic>>> getUserVehicles(String userEmail) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('vehicles')
          .where('userEmail', isEqualTo: userEmail)
          .get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      throw Exception('Error fetching vehicles: $e');
    }
  }

  // Starta parkering
  Future<bool> startParking({
    required String userEmail,
    required String registrationNumber,
    required String parkingSpaceId,
    required DateTime startTime,
    required DateTime endTime,
    required double totalCost,
  }) async {
    try {
      final docRef = await _firestore.collection('parkings').add({
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'totalCost': totalCost,
        'userEmail': userEmail,
        'vehicleRegistrationNumber': registrationNumber,
        'parkingSpaceId': parkingSpaceId,
        'status': 'active', // Kan användas för att skilja aktiva parkeringar
      });

      print('Parking created with ID: ${docRef.id}');
      return true; // Parkering startad
    } catch (e) {
      print('Error starting parking: $e');
      return false; // Fel inträffade
    }
  }

  // Hämta aktiva parkeringar
  Future<List<Parking>> getActiveParkings({required String userEmail}) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('parkings')
          .where('userEmail', isEqualTo: userEmail)
          .where('status', isEqualTo: 'active')
          .get();
      return snapshot.docs.map((doc) => Parking.fromJson(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      throw Exception('Error fetching active parkings: $e');
    }
  }

  // Hämta parkeringshistorik
  Future<List<Parking>> getParkingHistory({required String userEmail}) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('parkings')
          .where('userEmail', isEqualTo: userEmail)
          .where('status', isEqualTo: 'completed') // Historik baserad på status
          .get();
      return snapshot.docs.map((doc) => Parking.fromJson(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      throw Exception('Error fetching parking history: $e');
    }
  }

  // Uppdatera sluttiden för parkering
  Future<bool> updateParkingEndTime(String parkingId, DateTime newEndTime) async {
    print('Updating parking end time for ID: $parkingId with time: $newEndTime');
    try {
      // Kontrollera om dokumentet finns
      final docRef = _firestore.collection('parkings').doc(parkingId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        throw Exception('Parking document with ID $parkingId not found.');
      }

      // Uppdatera sluttiden
      await docRef.update({
        'endTime': newEndTime.toIso8601String(),
      });

      return true;
    } catch (e) {
      throw Exception('Error updating parking end time: $e');
    }
  }
}