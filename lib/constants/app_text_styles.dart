import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Serif Elegan untuk Judul & Branding
  static const TextStyle brandTitle = TextStyle(
    fontFamily: 'serif',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: 3.0,
    color: AppColors.deepBurgundy,
  );

  static const TextStyle brandSubtitle = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 2.5,
    color: AppColors.mochaBrown,
  );

  static const TextStyle tagline = TextStyle(
    fontFamily: 'serif',
    fontStyle: FontStyle.italic,
    fontSize: 13,
    color: AppColors.mochaBrown,
  );

  static const TextStyle headingLarge = TextStyle(
    fontFamily: 'serif',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.charcoal,
    letterSpacing: 0.5,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: 'serif',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.charcoal,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.charcoal,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 14,
    color: AppColors.charcoal,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 12,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 11,
    color: AppColors.textMuted,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'sans-serif',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.pureWhite,
  );
}
