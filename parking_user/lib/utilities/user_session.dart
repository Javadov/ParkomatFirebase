import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();

  factory UserSession() {
    return _instance;
  }

  UserSession._internal();

  String? email;
  int? userId; 
  List<Map<String, dynamic>> vehicles = [];

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email');
    userId = prefs.getInt('userId');
  }

  Future<void> saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (email != null && userId != null) {
      prefs.setString('email', email!);
      prefs.setInt('userId', userId!);
      prefs.setBool('isLoggedIn', true);
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('email');
    prefs.remove('userId');
    prefs.setBool('isLoggedIn', false);
    email = null;
    userId = null;
    vehicles.clear();
  }
}