import 'packing_item.dart';

class PackingRecommendation {
  final int id;
  final int trip;
  final List<PackingItem> recommendedItems;
  final double confidenceScore;
  final String modelVersion;
  final String? createdAt;

  PackingRecommendation({
    required this.id,
    required this.trip,
    required this.recommendedItems,
    required this.confidenceScore,
    required this.modelVersion,
    this.createdAt,
  });

  factory PackingRecommendation.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['recommended_items'] as List<dynamic>? ?? [];

    return PackingRecommendation(
      id: json['id'] ?? 0,
      trip: json['trip'] ?? 0,
      recommendedItems: itemsJson
          .map((item) => PackingItem.fromJson(item))
          .toList(),
      confidenceScore: _toDouble(json['confidence_score']) ?? 0,
      modelVersion: json['model_version'] ?? '',
      createdAt: json['created_at'],
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value.toString());
  }
}