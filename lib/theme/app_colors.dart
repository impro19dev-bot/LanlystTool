import 'package:flutter/material.dart';

/// Existing palette — do not change hex values.
abstract final class AppColors {
  static const navy = Color(0xFF1A325F);
  static const navyDeep = Color(0xFF152A52);
  static const navyBanner = Color(0xFF1E3A6E);
  static const bodyBg = Color(0xFFF2F3F5);
  static const cardBorder = Color(0xFFE0E3E8);
  static const textPrimary = Color(0xFF1A2B4A);
  static const textMuted = Color(0xFF6B7280);
  static const orange = Color(0xFFE67E22);
  static const teal = Color(0xFF1ABC9C);
  static const watermark = Color(0xFFD8DEE8);

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navyDeep, navy, navyBanner],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [navyBanner, navy, navyDeep],
  );

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: navy.withValues(alpha: 0.07),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];
}
