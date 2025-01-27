import 'package:objectbox/objectbox.dart';
import 'package:uuid/uuid.dart';
import '../util/validators.dart';
import '../util/serializer.dart';
import '../util/identifiable.dart';

@Entity()
class Vehicle extends Identifiable {
  @Id()
  int obxId = 0;

  @override
  String id;

  String registrationNumber;
  String type;

  @Property()
  String userEmail; 

  Vehicle(
    this.registrationNumber, 
    this.type, 
    this.userEmail, 
    String? id,
  ) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'registrationNumber': registrationNumber,
      'type': type,
      'userEmail': userEmail,
    };
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      json['registrationNumber'] as String,
      json['type'] as String,
      json['userEmail'] as String,
      json['id'] as String? ?? const Uuid().v4(),
    );
  }

  @override
  bool isValid() {
    return Validators.isValidRegistrationNumber(registrationNumber) &&
        Validators.isValidVehicleType(type);
  }

  @override
  String toString() {
    return "Id: $id, Registration Number: $registrationNumber, Type: $type, UserEmail: $userEmail";
  }
}

class VehicleSerializer extends Serializer<Vehicle> {
  @override
  Map<String, dynamic> toJson(Vehicle item) {
    return {
      'id': item.id,
      'registrationNumber': item.registrationNumber,
      'type': item.type,
      'userEmail': item.userEmail,
    };
  }

  @override
  Vehicle fromJson(Map<String, dynamic> json) {
    return Vehicle(
      json['registrationNumber'] as String,
      json['type'] as String,
      json['userEmail'] as String,
      json['id'] as String? ?? const Uuid().v4(),
    );
  }
}