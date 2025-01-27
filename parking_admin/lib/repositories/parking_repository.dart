import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parking_shared/models/parking.dart';

class ParkingRepository {
  final String baseUrl = 'http://localhost:8080';

  Future<List<Parking>> getAllParkings() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/parkings'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Parking.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch all parkings');
      }
    } catch (e) {
      throw Exception('Error fetching all parkings: $e');
    }
  }

  Future<List<Parking>> getActiveParkings() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/parkings/active'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Parking.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch active parkings');
      }
    } catch (e) {
      throw Exception('Error fetching active parkings: $e');
    }
  }

  Future<List<Parking>> getParkingHistory() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/parkings/history'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Parking.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch parking history');
      }
    } catch (e) {
      throw Exception('Error fetching parking history: $e');
    }
  }

  Future<bool> stopParking(String parkingId, DateTime endTime) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/parkings/$parkingId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'newEndTime': endTime.toIso8601String()}),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error stopping parking: $e');
    }
  }

  Future<bool> updateParkingEndTime(int parkingId, DateTime newEndTime) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/parkings/$parkingId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'newEndTime': newEndTime.toIso8601String()}),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating parking end time: $e');
    }
  }

  Future<bool> deleteParking(int parkingId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/parkings/$parkingId'));

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting parking: $e');
    }
  }

  Future<List<Parking>> searchParkings(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/parkings/search?query=$query'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Parking.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search parkings');
      }
    } catch (e) {
      throw Exception('Error searching parkings: $e');
    }
  }
}
