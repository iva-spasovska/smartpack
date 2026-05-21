import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../api_config.dart';
import 'api_client.dart';

class AuthService {
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.loginUrl),
      headers: ApiClient.jsonHeaders(),
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access', data['access']);
      await prefs.setString('refresh', data['refresh']);

      return true;
    }

    return false;
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String gender,
    required String dateOfBirth,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.registerUrl),
      headers: ApiClient.jsonHeaders(),
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'gender': gender,
        'date_of_birth': dateOfBirth,
      }),
    );

    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access');
    await prefs.remove('refresh');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access') != null;
  }
}