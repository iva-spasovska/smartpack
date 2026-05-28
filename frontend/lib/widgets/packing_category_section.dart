import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/packing_item.dart';
import 'packing_item_tile.dart';

class PackingCategorySection extends StatelessWidget {
  final String title;
  final List<PackingItem> items;
  final bool isReadOnly;
  final Function(PackingItem) onChecked;
  final Function(PackingItem) onIncrement;
  final Function(PackingItem) onDecrement;

  const PackingCategorySection({
    super.key,
    required this.title,
    required this.items,
    required this.isReadOnly,
    required this.onChecked,
    required this.onIncrement,
    required this.onDecrement,
  });

  static const Color darkBlue = Color(0xFF2F4858);
  static const Color primaryColor = Color(0xFF4F8D9C);
  static const Color lightBlue = Color(0xFFE8F3F7);

  @override
  Widget build(BuildContext context) {
    final checkedCount = items.where((item) => item.isChecked).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _categoryIcon(title),
                  color: primaryColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: darkBlue,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '$checkedCount/${items.length}',
                  style: GoogleFonts.poppins(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => PackingItemTile(
              item: item,
              isReadOnly: isReadOnly,
              onChecked: () => onChecked(item),
              onIncrement: () => onIncrement(item),
              onDecrement: () => onDecrement(item),
            ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String title) {
    final value = title.toLowerCase();
    if (value.contains('clothing') || value.contains('clothes')) {
      return Icons.checkroom_outlined;
    }
    if (value.contains('toiletries') || value.contains('hygiene')) {
      return Icons.spa_outlined;
    }
    if (value.contains('document')) return Icons.badge_outlined;
    if (value.contains('electronic')) return Icons.devices_outlined;
    if (value.contains('medicine') || value.contains('health')) {
      return Icons.medical_services_outlined;
    }
    if (value.contains('weather')) return Icons.cloud_outlined;
    return Icons.luggage_outlined;
  }
}
