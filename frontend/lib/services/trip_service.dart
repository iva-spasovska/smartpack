import 'dart:convert';
import 'package:http/http.dart' as http;

import '../api_config.dart';
import '../models/trip.dart';
import 'api_client.dart';

class TripService {
  Future<List<Trip>> getTrips() async {
    final response = await http.get(
      Uri.parse(ApiConfig.tripsUrl),
      headers: await ApiClient.authHeaders(),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      final List list = decoded is List ? decoded : decoded['results'];

      return list.map((item) => Trip.fromJson(item)).toList();
    }

    throw Exception('Failed to load trips');
  }

  Future<Trip> createTrip(Trip trip) async {
    final response = await http.post(
      Uri.parse(ApiConfig.tripsUrl),
      headers: await ApiClient.authHeaders(),
      body: jsonEncode(trip.toCreateJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Trip.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to create trip');
  }

  Future<void> deleteTrip(int tripId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.tripsUrl}$tripId/'),
      headers: await ApiClient.authHeaders(),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete trip');
    }
  }
}