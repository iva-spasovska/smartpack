import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

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

  Future<AppUser> updateProfile({
    required String username,
    required String? gender,
    required String? dateOfBirth,
  }) async {
    final response = await http.patch(
      Uri.parse(ApiConfig.profileUrl),
      headers: await ApiClient.authHeaders(),
      body: jsonEncode({
        'username': username,
        'gender': gender,
        'date_of_birth': dateOfBirth,
      }),
    );

    if (response.statusCode == 200) {
      return AppUser.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to update user profile');
  }

  Future<AppUser> uploadProfilePhoto(XFile image) async {
    final headers = await ApiClient.authHeaders();
    headers.remove('Content-Type');

    final request = http.MultipartRequest(
      'PATCH',
      Uri.parse(ApiConfig.profileUrl),
    );
    request.headers.addAll(headers);
    request.files.add(
      await http.MultipartFile.fromPath(
        'profile_photo',
        image.path,
        filename: image.name,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return AppUser.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to upload profile photo');
  }
}
