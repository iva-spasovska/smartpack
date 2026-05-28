import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.compact = false,
    this.showTagline = true,
    this.textColor = const Color(0xFF2F4858),
    this.accentColor = const Color(0xFF4F8D9C),
    this.iconBackground = const Color(0xFF2F4858),
  });

  final bool compact;
  final bool showTagline;
  final Color textColor;
  final Color accentColor;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 44.0 : 54.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(compact ? 14 : 16),
          ),
          child: Icon(
            Icons.luggage_rounded,
            color: Colors.white,
            size: compact ? 24 : 28,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PackPal',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: textColor,
                  fontSize: compact ? 22 : 28,
                  height: 1.05,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (showTagline) ...[
                const SizedBox(height: 3),
                Text(
                  'pack smart | travel easy',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: accentColor,
                    fontSize: compact ? 10 : 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
