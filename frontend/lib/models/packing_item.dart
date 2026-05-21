class PackingItem {
  final String id;
  final String name;
  final String category;
  int quantity;
  bool isChecked;
  final bool isRequired;

  PackingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.isChecked,
    required this.isRequired,
  });

  factory PackingItem.fromJson(Map<String, dynamic> json) {
    return PackingItem(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      category: json['category'] ?? 'other',
      quantity: json['quantity'] ?? 1,
      isChecked: json['is_checked'] ?? false,
      isRequired: json['is_required'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'is_checked': isChecked,
      'is_required': isRequired,
    };
  }
}