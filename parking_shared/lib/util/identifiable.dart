import 'package:objectbox/objectbox.dart';

abstract class Identifiable {
  @Id()
  String get id;
  set id(String value);
  bool isValid();
}
