import 'dart:convert';
import 'package:http/http.dart' as http;

import '../api_config.dart';
import '../models/app_user.dart';
import 'api_client.dart';

class UserService {
  Future<AppUser> getProfile() async {
    final response = await http.get(
      Uri.parse(ApiConfig.profileUrl),
      headers: await ApiClient.authHeaders(),
    );

    if (response.statusCode == 200) {
      return AppUser.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to load user profile');
  }
}