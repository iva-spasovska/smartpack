import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/packing_item.dart';
import 'packing_item_tile.dart';

class PackingCategorySection extends StatelessWidget {
  final String title;
  final List<PackingItem> items;
  final Function(PackingItem) onChecked;
  final Function(PackingItem) onIncrement;
  final Function(PackingItem) onDecrement;

  const PackingCategorySection({
    super.key,
    required this.title,
    required this.items,
    required this.onChecked,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2F4858),
            ),
          ),

          const SizedBox(height: 16),

          ...items.map(
            (item) => PackingItemTile(
              item: item,
              onChecked: () => onChecked(item),
              onIncrement: () => onIncrement(item),
              onDecrement: () => onDecrement(item),
            ),
          ),
        ],
      ),
    );
  }
}