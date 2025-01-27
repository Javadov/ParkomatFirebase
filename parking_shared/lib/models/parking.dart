import 'package:objectbox/objectbox.dart';
import 'package:uuid/uuid.dart';
import '../util/serializer.dart';
import '../util/identifiable.dart';

@Entity()
class Parking extends Identifiable {
  @Id()
  int obxId = 0;

  @override
  String id;

  @Property(type: PropertyType.date)
  DateTime startTime;

  @Property(type: PropertyType.date)
  DateTime? endTime;

  double totalCost;

  @Property()
  String userEmail; // Reference to User by email

  @Property()
  String vehicleRegistrationNumber; // Relation to Vehicle

  @Property()
  String parkingSpaceId; // Relation to ParkingSpace

  Parking({
    required this.startTime,
    this.endTime,
    required this.totalCost,
    required this.userEmail,
    required this.vehicleRegistrationNumber,
    required this.parkingSpaceId,
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'totalCost': totalCost,
      'userEmail': userEmail,
      'vehicleRegistrationNumber': vehicleRegistrationNumber,
      'parkingSpaceId': parkingSpaceId,
    };
  }

  factory Parking.fromJson(Map<String, dynamic> json, String documentId) {
    return Parking(
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      totalCost: json['totalCost'] as double,
      userEmail: json['userEmail'] as String,
      vehicleRegistrationNumber: json['vehicleRegistrationNumber'] as String,
      parkingSpaceId: json['parkingSpaceId'] as String,
      id: documentId,
    );
  }

  @override
  bool isValid() {
    return totalCost >= 0;
  }

  @override
  String toString() {
    return "Id: $id, Start Time: $startTime, End Time: $endTime, Total Cost: \$${totalCost.toStringAsFixed(2)}, UserEmail: $userEmail, vehicleRegistrationNumber: $vehicleRegistrationNumber, ParkingSpaceId: $parkingSpaceId";
  }
}

class ParkingSerializer extends Serializer<Parking> {
  @override
  Map<String, dynamic> toJson(Parking item) {
    return {
      'id': item.id,
      'startTime': item.startTime.toIso8601String(),
      'endTime': item.endTime?.toIso8601String(),
      'totalCost': item.totalCost,
      'userEmail': item.userEmail,
      'vehicleRegistrationNumber': item.vehicleRegistrationNumber,
      'parkingSpaceId': item.parkingSpaceId,
    };
  }

  @override
  Parking fromJson(Map<String, dynamic> json) {
    return Parking(
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      totalCost: json['totalCost'] as double,
      userEmail: json['userEmail'] as String,
      vehicleRegistrationNumber: json['vehicleRegistrationNumber'] as String,
      parkingSpaceId: json['parkingSpaceId'] as String,
      id: json['id'] as String? ?? const Uuid().v4(),
    );
  }
}