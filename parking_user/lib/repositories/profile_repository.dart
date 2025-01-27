import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Hämtar användarens e-post baserat på sessionens e-post.
  Future<String?> fetchUserEmail(String sessionEmail) async {
    try {
      final doc = await _firestore.collection('users').doc(sessionEmail).get();
      if (doc.exists) {
        return doc.data()?['email'];
      } else {
        throw Exception('Användaren hittades inte.');
      }
    } catch (e) {
      debugPrint('Error fetching user email: $e');
      return null;
    }
  }

  /// Hämtar användarens fordon baserat på e-post.
  Future<List<Map<String, dynamic>>> fetchUserVehicles(String email) async {
    try {
      final snapshot = await _firestore
          .collection('vehicles')
          .where('userEmail', isEqualTo: email)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint('Error fetching vehicles: $e');
      return [];
    }
  }

  /// Uppdaterar användarens e-postadress.
  Future<bool> updateUserEmail(String currentEmail, String newEmail) async {
    try {
      final userDoc = _firestore.collection('users').doc(currentEmail);

      final snapshot = await userDoc.get();
      if (snapshot.exists) {
        await _firestore.runTransaction((transaction) async {
          // Uppdatera användarens e-post
          transaction.update(userDoc, {'email': newEmail});

          // Flytta fordon till den nya e-posten
          final vehicleDocs = await _firestore
              .collection('vehicles')
              .where('userEmail', isEqualTo: currentEmail)
              .get();

          for (var vehicle in vehicleDocs.docs) {
            transaction.update(vehicle.reference, {'userEmail': newEmail});
          }
        });
        return true;
      } else {
        throw Exception('Användaren hittades inte.');
      }
    } catch (e) {
      debugPrint('Error updating email: $e');
      return false;
    }
  }

  /// Lägger till ett nytt fordon för användaren.
  Future<bool> addVehicle(
      String email, String registrationNumber, String type) async {
    try {
      await _firestore.collection('vehicles').add({
        'userEmail': email,
        'registrationNumber': registrationNumber,
        'type': type,
      });
      return true;
    } catch (e) {
      debugPrint('Error adding vehicle: $e');
      return false;
    }
  }

  /// Uppdaterar informationen för ett specifikt fordon.
  Future<bool> updateVehicle(String id, Map<String, dynamic> updatedVehicle) async {
    try {
      await _firestore.collection('vehicles').doc(id).update(updatedVehicle);
      return true;
    } catch (e) {
      debugPrint('Error updating vehicle: $e');
      return false;
    }
  }

  /// Tar bort ett fordon baserat på ID.
  Future<bool> deleteVehicle(String id) async {
    try {
      await _firestore.collection('vehicles').doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting vehicle: $e');
      return false;
    }
  }
}