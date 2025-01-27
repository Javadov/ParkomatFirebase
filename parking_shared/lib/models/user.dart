import 'package:objectbox/objectbox.dart';
import 'package:uuid/uuid.dart';
import '../util/validators.dart';
import '../util/serializer.dart';
import '../util/identifiable.dart';

@Entity()
class User extends Identifiable {
  @Id()
  int obxId = 0;

  @override
  String id;
  String name;

  @Unique()
  String email;
  String password;

  User(
    this.name, 
    this.email, 
    this.password, 
    String? id,
  ) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
    };
  }
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['name'] as String,
      json['email'] as String,
      json['password'] as String,
      json['id'] as String? ?? const Uuid().v4(),
    );
  }

  @override
  bool isValid() {
    return Validators.isValidName(name) &&
        Validators.isValidEmail(email) &&
        password.isNotEmpty;
  }

  @override
  String toString() {
    return "Id: $id, Name: $name, Email: $email";
  }
}

class UserSerializer extends Serializer<User> {
  @override
  Map<String, dynamic> toJson(User item) {
    return {
      'id': item.id,
      'name': item.name,
      'email': item.email,
      'password': item.password,
    };
  }

  @override
  User fromJson(Map<String, dynamic> json) {
    return User(
      json['name'] as String,
      json['email'] as String,
      json['password'] as String,
      json['id'] as String? ?? const Uuid().v4(),
    );
  }
}
