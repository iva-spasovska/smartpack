import 'package:frontend/models/packing_item.dart';

class TripPackingItem {
  final int id;
  final int trip;
  final PackingItem item;
  int quantity;
  bool isChecked;

  TripPackingItem({
    required this.id,
    required this.trip,
    required this.item,
    required this.quantity,
    required this.isChecked,
  });

  factory TripPackingItem.fromJson(Map<String, dynamic> json) {
    return TripPackingItem(
      id: json['id'],
      trip: json['trip'],
      item: PackingItem.fromJson(json['item']),
      quantity: json['quantity'] ?? 1,
      isChecked: json['is_checked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trip': trip,
      'item_id': item.id,
      'quantity': quantity,
      'is_checked': isChecked,
    };
  }
}
