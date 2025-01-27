import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ProfileRepository {
  final String baseUrl = 'http://localhost:8080';

  /// Hämtar användarens e-post baserat på sessionens e-post.
  Future<String?> fetchUserEmail(String sessionEmail) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/$sessionEmail'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['email'];
      } else {
        throw Exception('Failed to fetch user email');
      }
    } catch (e) {
      debugPrint('Error fetching user email: $e');
      return null;
    }
  }

  /// Hämtar användarens fordon baserat på e-post.
  Future<List<Map<String, dynamic>>> fetchUserVehicles(String email) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/vehicles/$email'));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch user vehicles');
      }
    } catch (e) {
      debugPrint('Error fetching vehicles: $e');
      return [];
    }
  }

  /// Uppdaterar användarens e-postadress.
  Future<bool> updateUserEmail(String currentEmail, String newEmail) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': currentEmail, 'newEmail': newEmail}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating email: $e');
      return false;
    }
  }

  /// Lägger till ett nytt fordon för användaren.
  Future<bool> addVehicle(String email, String registrationNumber, String type) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/vehicles'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userEmail': email,
          'registrationNumber': registrationNumber,
          'type': type,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error adding vehicle: $e');
      return false;
    }
  }

  /// Uppdaterar informationen för ett specifikt fordon.
  Future<bool> updateVehicle(int id, Map<String, dynamic> updatedVehicle) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/vehicles/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedVehicle),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating vehicle: $e');
      return false;
    }
  }

  /// Tar bort ett fordon baserat på registreringsnumret.
  Future<bool> deleteVehicle(String registrationNumber) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/vehicles/$registrationNumber'));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting vehicle: $e');
      return false;
    }
  }
}