import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parking_shared/models/parking_space.dart';

class ParkingSpaceRepository {
  // Firestore-instans
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 1) Lägg till en ny ParkingSpace
  ///    Returnerar true om det går bra, annars kastar vi en exception i catch.
  Future<bool> addParkingSpace(ParkingSpace parkingSpace) async {
    try {
      // Om du redan har ett sträng-ID i parkingSpace.id:
      //   await _firestore.collection('parking_spaces').doc(parkingSpace.id).set(parkingSpace.toJson());
      // Om du istället vill auto-generera ett dokument-ID (och ej har parkingSpace.id):
      final docRef = await _firestore.collection('parking_spaces').add(parkingSpace.toJson());

      // Vill du spara docRef.id i ParkingSpace? Du kan uppdatera koden nedan.
      // parkingSpace.id = docRef.id;

      return true;
    } catch (e) {
      throw Exception('Failed to add parking space: $e');
    }
  }

  /// 2) Uppdatera en ParkingSpace
  ///    Returnerar true om allt går bra.
  Future<bool> updateParkingSpace(ParkingSpace parkingSpace) async {
    try {
      // Om parkingSpace.id är ett sträng-ID och redan existerar i Firestore:
      await _firestore
          .collection('parking_spaces')
          .doc(parkingSpace.id)
          .update(parkingSpace.toJson());

      return true;
    } catch (e) {
      throw Exception('Failed to update parking space: $e');
    }
  }

  /// 3) Radera en ParkingSpace
  ///    Antas att `id` är samma sträng som Firestore-dokumentet använder.
  Future<bool> deleteParkingSpace(String id) async {
    try {
      await _firestore.collection('parking_spaces').doc(id).delete();
      return true;
    } catch (e) {
      throw Exception('Failed to delete parking space: $e');
    }
  }

  /// 4) Hämta alla ParkingSpaces
  Future<List<ParkingSpace>> getAllParkingSpaces() async {
    try {
      final snapshot = await _firestore.collection('parking_spaces').get();

      // Konvertera varje dokument till ett ParkingSpace-objekt.
      // Om din ParkingSpace.fromJson() behöver "id" i objektet kan du
      // stoppa in doc.id i datan:
      //   final data = doc.data();
      //   data['id'] = doc.id;
      //   ParkingSpace.fromJson(data);

      final List<ParkingSpace> spaces = snapshot.docs.map((doc) {
        final data = doc.data();
        // Om din ParkingSpace har en sträng-id i sin fromJson:
        data['id'] = doc.id; // Tvingar in docId i 'id'-fältet
        return ParkingSpace.fromJson(data);
      }).toList();

      return spaces;
    } catch (e) {
      throw Exception('Error fetching parking spaces: $e');
    }
  }
}