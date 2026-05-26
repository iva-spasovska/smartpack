import 'dart:convert';
import 'package:http/http.dart' as http;

import '../api_config.dart';
import '../models/packing_item.dart';
import '../models/user_packing_list.dart';
import 'api_client.dart';

class PackingListService {
  Future<UserPackingList?> getUserPackingList(int tripId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.packingUrl}user-list/$tripId/'),
      headers: await ApiClient.authHeaders(),
    );

    if (response.statusCode == 200) {
      return UserPackingList.fromJson(jsonDecode(response.body));
    }

    return null;
  }

  Future<UserPackingList> saveUserPackingList({
    required int tripId,
    required List<PackingItem> items,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.packingUrl}user-list/'),
      headers: await ApiClient.authHeaders(),
      body: jsonEncode({
        'trip_id': tripId,
        'items': items.map((item) => item.toJson()).toList(),
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return UserPackingList.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to save packing list');
  }
}