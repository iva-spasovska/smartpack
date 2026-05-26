import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/packing_item.dart';

class PackingItemTile extends StatelessWidget {
  final PackingItem item;
  final VoidCallback onChecked;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const PackingItemTile({
    super.key,
    required this.item,
    required this.onChecked,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Checkbox(
            value: item.isChecked,
            onChanged: (_) => onChecked(),
          ),

          Expanded(
            child: Text(
              item.name,
              style: GoogleFonts.poppins(
                fontSize: 15,
                decoration:
                    item.isChecked ? TextDecoration.lineThrough : null,
              ),
            ),
          ),

          IconButton(
            onPressed: onDecrement,
            icon: const Icon(Icons.remove_circle_outline),
          ),

          Text(
            item.quantity.toString(),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),

          IconButton(
            onPressed: onIncrement,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
}