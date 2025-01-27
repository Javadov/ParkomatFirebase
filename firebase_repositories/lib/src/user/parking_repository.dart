import 'dart:convert'; // ev. inte behövs längre
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:parking_shared/models/parking.dart';
import 'package:parking_shared/models/parking_space.dart';

class ParkingRepository {
  // Referens till Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 1) Hämta alla ParkingSpaces
  Future<List<ParkingSpace>> getAllParkingSpaces() async {
    final snapshot = await _firestore.collection('parking_spaces').get();

    // Varje doc här motsvarar en parkingSpace
    return snapshot.docs.map((doc) {
      final data = doc.data();
      // Du kan behöva justera fromJson beroende på hur
      // ParkingSpace.fromJson är implementerad.
      return ParkingSpace.fromJson(data);
    }).toList();
  }

  /// 2) Sök ParkingSpaces (enkel variant: hämta ALLT och filtrera i minnet)
  Future<List<ParkingSpace>> searchParkingSpaces(String query) async {
    try {
      final snapshot = await _firestore.collection('parking_spaces').get();
      final allSpaces = snapshot.docs.map((doc) {
        return ParkingSpace.fromJson(doc.data());
      }).toList();

      // Filtrerar lokalt på t.ex. name, id etc.
      return allSpaces.where((space) {
        // Justera efter vilka fält du vill söka på
        final nameMatches = space.address.toLowerCase().contains(query.toLowerCase());
        // Lägg till fler villkor om du har andra relevanta fält
        return nameMatches;
      }).toList();
    } catch (e) {
      throw Exception('Error searching parking spaces: $e');
    }
  }

  /// 3) Hämta användarens fordon (vehicles)
  ///    Returnerar List<Map<String,dynamic>> för att matcha din gamla signatur
  Future<List<Map<String, dynamic>>> getUserVehicles(String userEmail) async {
    try {
      final snapshot = await _firestore
          .collection('vehicles')
          .where('userEmail', isEqualTo: userEmail)
          .get();

      // Om du föredrar en riktig modellklass, kan du ersätta med fromJson.
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Error fetching vehicles: $e');
    }
  }

  /// 4) startParking
  ///    - I originalet skickas `parkingSpaceId` som int,
  ///      men Firestore-dokument-id är normalt en sträng.
  ///    - Här lagrar vi helt enkelt 'parkingSpaceId' som ett fält av typen int.
  Future<bool> startParking({
    required String userEmail,
    required String registrationNumber,
    required int parkingSpaceId,
    required DateTime startTime,
    required DateTime endTime,
    required double totalCost,
  }) async {
    try {
      await _firestore.collection('parkings').add({
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'totalCost': totalCost,
        'userEmail': userEmail,
        'vehicleRegistrationNumber': registrationNumber,
        'parkingSpaceId': parkingSpaceId, // vi sparar den som int
      });
      return true; // Parking start successful
    } catch (e) {
      print('Error starting parking: $e');
      return false; // Error occurred
    }
  }

  /// 5) getActiveParkings
  ///    - Firestore saknar OR-query (endTime == null || endTime > now),
  ///      så vi gör en .where('userEmail') men filtrerar sedan i minnet.
  Future<List<Parking>> getActiveParkings({required String userEmail}) async {
    try {
      final snapshot = await _firestore
          .collection('parkings')
          .where('userEmail', isEqualTo: userEmail)
          .get();

      final allParkings = snapshot.docs.map((doc) {
        return Parking.fromJson(doc.data());
      }).toList();

      // Filtrerar lokalt endTime == null eller endTime > now
      final now = DateTime.now();
      final active = allParkings.where((p) {
        if (p.endTime == null) return true;
        return p.endTime!.isAfter(now);
      }).toList();

      return active;
    } catch (e) {
      throw Exception('Error fetching active parkings: $e');
    }
  }

  /// 6) getParkingHistory
  ///    - Samma logik, men filtrerar endTime < now
  Future<List<Parking>> getParkingHistory({required String userEmail}) async {
    try {
      final snapshot = await _firestore
          .collection('parkings')
          .where('userEmail', isEqualTo: userEmail)
          .get();

      final allParkings = snapshot.docs.map((doc) {
        return Parking.fromJson(doc.data());
      }).toList();

      final now = DateTime.now();
      final history = allParkings.where((p) {
        // endTime != null && endTime < now
        if (p.endTime == null) return false;
        return p.endTime!.isBefore(now);
      }).toList();

      return history;
    } catch (e) {
      throw Exception('Error fetching parking history: $e');
    }
  }

  /// 7) updateParkingEndTime
  ///    - Du har "int parkingId" i signaturen, men Firestore docId är string.
  ///    - Lösning: spara "parkingId" som fält i dokumentet, hitta dokumentet via en .where
  Future<bool> updateParkingEndTime(int parkingId, DateTime newEndTime) async {
    try {
      // Hitta dokumentet som har detta parkingId
      final query = await _firestore
          .collection('parkings')
          .where('parkingSpaceId', isEqualTo: parkingId) // Exempel: "parkingSpaceId" eller "parkingId"
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('No parking found with parkingId = $parkingId');
      }

      // Vi tar första träffen
      final docRef = query.docs.first.reference;

      // Uppdaterar endTime
      await docRef.update({
        'endTime': newEndTime.toIso8601String(),
      });

      return true;
    } catch (e) {
      throw Exception('Error updating parking end time: $e');
    }
  }
}