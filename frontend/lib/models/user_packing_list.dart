import 'packing_item.dart';

class UserPackingList {
  final int id;
  final int? tripId;
  final String? tripName;
  final String? destination;
  final List<PackingItem> items;
  final String? createdAt;
  final String? updatedAt;

  UserPackingList({
    required this.id,
    this.tripId,
    this.tripName,
    this.destination,
    required this.items,
    this.createdAt,
    this.updatedAt,
  });

  factory UserPackingList.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];

    return UserPackingList(
      id: json['id'] ?? 0,
      tripId: json['trip_id'],
      tripName: json['trip_name'],
      destination: json['destination'],
      items: itemsJson
          .map((item) => PackingItem.fromJson(item))
          .toList(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}