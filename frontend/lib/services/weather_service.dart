import 'dart:convert';
import 'package:http/http.dart' as http;

import '../api_config.dart';
import '../models/weather_snapshot.dart';
import 'api_client.dart';

class WeatherService {
  Future<WeatherSnapshot?> getWeatherForTrip(int tripId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.weatherUrl}$tripId/'),
      headers: await ApiClient.authHeaders(),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is List && decoded.isNotEmpty) {
        return WeatherSnapshot.fromJson(decoded.first);
      }

      if (decoded is Map<String, dynamic>) {
        return WeatherSnapshot.fromJson(decoded);
      }

      return null;
    }

    return null;
  }
}