import 'dart:ui';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B83FF);
  static const Color primaryDark = Color(0xFF4A42B8);

  // Secondary colors
  static const Color secondary = Color(0xFFFF6588);
  static const Color secondaryLight = Color(0xFFFF8CAA);
  static const Color secondaryDark = Color(0xFFCC4166);

  // Accent colors
  static const Color accent = Color(0xFF00C9A7);
  static const Color accentLight = Color(0xFF33D9B9);
  static const Color accentDark = Color(0xFF009E84);

  // Status colors
  static const Color success = Color(0xFF2ED573);
  static const Color warning = Color(0xFFFFA502);
  static const Color error = Color(0xFFFF4757);
  static const Color info = Color(0xFF1E90FF);

  // Neutral colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);

  // Text colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textLight = Color(0xFFFFFFFF);

  // Border colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF0F0F0);
  static const Color borderDark = Color(0xFFBDBDBD);

  // Gradient colors
  static const List<Color> primaryGradient = [
    primary,
    primaryDark,
  ];

  static const List<Color> secondaryGradient = [
    secondary,
    secondaryDark,
  ];

  static const List<Color> matchGradient = [
    Color(0xFFFF6B6B),
    Color(0xFF6C63FF),
  ];

  // Shadow colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);

  // Overlay colors
  static const Color overlayLight = Color(0x33FFFFFF);
  static const Color overlayDark = Color(0x66000000);
}