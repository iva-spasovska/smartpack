import 'dart:convert';
import 'package:http/http.dart' as http;

import '../api_config.dart';
import '../models/packing_recommendation.dart';
import 'api_client.dart';

class RecommendationService {
  Future<PackingRecommendation?> getRecommendationForTrip(int tripId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.mlUrl}$tripId/'),
      headers: await ApiClient.authHeaders(),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is List && decoded.isNotEmpty) {
        return PackingRecommendation.fromJson(decoded.first);
      }

      if (decoded is Map<String, dynamic>) {
        return PackingRecommendation.fromJson(decoded);
      }

      return null;
    }

    return null;
  }
}