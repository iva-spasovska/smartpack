import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static Future<Map<String, String>> authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access');

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Map<String, String> jsonHeaders() {
    return {
      'Content-Type': 'application/json',
    };
  }
}