import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parking_shared/models/parking.dart';

class ParkingRepository {
  // Firestore-instans
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 1. Hämta alla parkeringar
  Future<List<Parking>> getAllParkings() async {
    try {
      final snapshot = await _firestore.collection('parkings').get();
      final parkings = snapshot.docs.map((doc) {
        // Antar att Parking.fromJson(Map<String,dynamic>) finns
        return Parking.fromJson(doc.data());
      }).toList();
      return parkings;
    } catch (e) {
      throw Exception('Error fetching all parkings: $e');
    }
  }

  /// 2. Hämta aktiva parkeringar (endTime är null eller i framtiden)
  Future<List<Parking>> getActiveParkings() async {
    try {
      // Hämta alla parkeringar och filtrera i minnet
      final snapshot = await _firestore.collection('parkings').get();
      final allParkings = snapshot.docs
          .map((doc) => Parking.fromJson(doc.data()))
          .toList();

      final now = DateTime.now();
      // Filtrera ut aktiva
      return allParkings.where((p) {
        return p.endTime == null || p.endTime!.isAfter(now);
      }).toList();
    } catch (e) {
      throw Exception('Error fetching active parkings: $e');
    }
  }

  /// 3. Hämta historiska parkeringar (endTime i dåtiden)
  Future<List<Parking>> getParkingHistory() async {
    try {
      // Hämta alla parkeringar och filtrera i minnet
      final snapshot = await _firestore.collection('parkings').get();
      final allParkings = snapshot.docs
          .map((doc) => Parking.fromJson(doc.data()))
          .toList();

      final now = DateTime.now();
      // Filtrera ut de som är klara/historiska
      return allParkings.where((p) {
        return p.endTime != null && p.endTime!.isBefore(now);
      }).toList();
    } catch (e) {
      throw Exception('Error fetching parking history: $e');
    }
  }

  /// 4. stopParking - uppdaterar endTime på docId = parkingId (om parkingId är sträng)
  Future<bool> stopParking(String parkingId, DateTime endTime) async {
    try {
      // Här antar vi att dokument-ID i Firestore är samma som parkingId
      final docRef = _firestore.collection('parkings').doc(parkingId);

      await docRef.update({
        'endTime': endTime.toIso8601String(), 
        // eller använd Timestamp: Timestamp.fromDate(endTime)
      });
      return true;
    } catch (e) {
      throw Exception('Error stopping parking: $e');
    }
  }

  /// 5. Uppdatera endTime baserat på ett int 'parkingId' som finns som fält
  ///    => letar först upp dokumentet via .where('parkingId', isEqualTo: parkingId).
  Future<bool> updateParkingEndTime(int parkingId, DateTime newEndTime) async {
    try {
      // Hitta dokumentet med field "parkingId" == parkingId
      final query = await _firestore
          .collection('parkings')
          .where('parkingId', isEqualTo: parkingId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('No parking found with parkingId = $parkingId');
      }

      final docRef = query.docs.first.reference;
      await docRef.update({
        'endTime': newEndTime.toIso8601String(),
      });
      return true;
    } catch (e) {
      throw Exception('Error updating parking end time: $e');
    }
  }

  /// 6. Radera en parkering via int 'parkingId' som lagras som fält i Firestore
  Future<bool> deleteParking(int parkingId) async {
    try {
      // Hitta dokument
      final query = await _firestore
          .collection('parkings')
          .where('parkingId', isEqualTo: parkingId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        // Hittar inget med detta parkingId
        return false;
      }

      final docRef = query.docs.first.reference;
      await docRef.delete();
      return true;
    } catch (e) {
      throw Exception('Error deleting parking: $e');
    }
  }

  /// 7. Sök bland parkeringar genom att hämta alla och filtrera i minnet
  Future<List<Parking>> searchParkings(String query) async {
    try {
      final snapshot = await _firestore.collection('parkings').get();
      final allParkings = snapshot.docs
          .map((doc) => Parking.fromJson(doc.data()))
          .toList();

      return allParkings.where((p) {
        // Exempel: matcha på parkingId, vehicleRegistrationNumber, startTime, endTime, etc.
        final matchesId = p.parkingSpaceId
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase());
        final matchesVehicle = (p.vehicleRegistrationNumber ?? '')
            .toLowerCase()
            .contains(query.toLowerCase());
        final matchesStart = p.startTime
            .toIso8601String()
            .toLowerCase()
            .contains(query.toLowerCase());
        final matchesEnd = (p.endTime?.toIso8601String() ?? '')
            .toLowerCase()
            .contains(query.toLowerCase());

        return matchesId || matchesVehicle || matchesStart || matchesEnd;
      }).toList();
    } catch (e) {
      throw Exception('Error searching parkings: $e');
    }
  }
}