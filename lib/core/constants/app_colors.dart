import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const primaryBlue = Color(0xFF2979FF);
  static const primaryBlueDark = Color(0xFF1A56CC);
  static const primaryBlueLight = Color(0xFFE3F2FD);
  
  // Accents
  static const accentPurple = Color(0xFFC58AF9);
  static const accentRed = Color(0xFFF28B82);
  
  // Neutrals - Dark Mode (AMOLED)
  static const darkBackground = Color(0xFF000000);
  static const darkSurface = Color(0xFF121212);
  static const darkCard = Color(0xFF1A1A1A);
  static const darkOutline = Color(0xFF2D2D2D);
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFF9E9E9E);
  
  // Neutrals - Light Mode
  static const lightBackground = Color(0xFFF8F9FA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFF1F3F4);
  static const lightOutline = Color(0xFFDADCE0);
  static const lightTextPrimary = Color(0xFF202124);
  static const lightTextSecondary = Color(0xFF5F6368);

  // Gradient helper (context-aware)
  static LinearGradient cardGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark 
        ? [const Color(0xFF202124), const Color(0xFF121212)]
        : [const Color(0xFFF8F9FA), const Color(0xFFF1F3F4)],
    );
  }
}
