import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class LogoWidget extends StatelessWidget {
  final double fontSize;
  final bool showTagline;
  final Color? primaryColor;
  final Color? secondaryColor;

  const LogoWidget({
    super.key,
    this.fontSize = 24,
    this.showTagline = false,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = primaryColor ?? AppColors.deepBurgundy;
    final subtitleColor = secondaryColor ?? AppColors.mochaBrown;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Ornamen Garis Minimalis
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 24, height: 1, color: AppColors.champagne),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.diamond_outlined, size: fontSize * 0.5, color: AppColors.champagne),
            ),
            Container(width: 24, height: 1, color: AppColors.champagne),
          ],
        ),
        const SizedBox(height: 6),
        // Tulisan Utama: TALENTA
        Text(
          'TALENTA',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 4.0,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 2),
        // Tulisan EVENT ORGANIZER berukuran lebih kecil di bawahnya
        Text(
          'EVENT ORGANIZER',
          style: TextStyle(
            fontFamily: 'sans-serif',
            fontSize: fontSize * 0.38,
            fontWeight: FontWeight.w600,
            letterSpacing: 3.5,
            color: subtitleColor,
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 8),
          Text(
            '“Every Moment, Beautifully Planned.”',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'serif',
              fontStyle: FontStyle.italic,
              fontSize: fontSize * 0.42,
              color: AppColors.mochaBrown,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ],
    );
  }
}
