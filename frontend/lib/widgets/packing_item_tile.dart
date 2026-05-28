import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/packing_item.dart';

class PackingItemTile extends StatelessWidget {
  final PackingItem item;
  final bool isReadOnly;
  final VoidCallback onChecked;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const PackingItemTile({
    super.key,
    required this.item,
    required this.isReadOnly,
    required this.onChecked,
    required this.onIncrement,
    required this.onDecrement,
  });

  static const Color darkBlue = Color(0xFF2F4858);
  static const Color primaryColor = Color(0xFF4F8D9C);
  static const Color lightBlue = Color(0xFFE8F3F7);
  static const Color softMint = Color(0xFFC7DDE8);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 11, 10, 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.isChecked
              ? primaryColor.withValues(alpha: 0.45)
              : softMint,
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: isReadOnly ? null : onChecked,
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: item.isChecked ? primaryColor : lightBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.isChecked ? Icons.check_rounded : Icons.circle_outlined,
                color: item.isChecked ? Colors.white : primaryColor,
                size: item.isChecked ? 21 : 15,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: item.isChecked
                        ? darkBlue.withValues(alpha: 0.48)
                        : darkBlue,
                    fontSize: 14,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                    decoration: item.isChecked
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (item.isRequired) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Recommended',
                    style: GoogleFonts.poppins(
                      color: primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 34,
            decoration: BoxDecoration(
              color: lightBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _QuantityButton(
                  icon: Icons.remove_rounded,
                  onPressed: isReadOnly ? null : onDecrement,
                ),
                SizedBox(
                  width: 28,
                  child: Text(
                    item.quantity.toString(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: darkBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _QuantityButton(
                  icon: Icons.add_rounded,
                  onPressed: isReadOnly ? null : onIncrement,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      color: PackingItemTile.darkBlue,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 30, height: 34),
      visualDensity: VisualDensity.compact,
    );
  }
}
