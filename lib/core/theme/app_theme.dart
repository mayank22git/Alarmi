import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryBlue,
        secondary: AppColors.accentPurple,
        tertiary: AppColors.accentRed,
        surface: AppColors.darkSurface,
        background: AppColors.darkBackground,
        onSurface: AppColors.darkTextPrimary,
        onBackground: AppColors.darkTextPrimary,
        outline: AppColors.darkOutline,
        surfaceVariant: AppColors.darkCard,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.primaryBlue.withOpacity(0.2),
        iconTheme: MaterialStateProperty.all(const IconThemeData(size: 24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: AppColors.darkTextSecondary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) => 
          states.contains(MaterialState.selected) ? AppColors.primaryBlue : AppColors.darkTextSecondary),
        trackColor: MaterialStateProperty.resolveWith((states) => 
          states.contains(MaterialState.selected) ? AppColors.primaryBlue.withOpacity(0.5) : AppColors.darkOutline),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.darkTextPrimary),
        displayMedium: TextStyle(color: AppColors.darkTextPrimary),
        headlineLarge: TextStyle(color: AppColors.darkTextPrimary),
        titleLarge: TextStyle(color: AppColors.darkTextPrimary),
        bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
        bodyMedium: TextStyle(color: AppColors.darkTextSecondary),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue,
        secondary: AppColors.accentPurple,
        tertiary: AppColors.accentRed,
        surface: AppColors.lightSurface,
        background: AppColors.lightBackground,
        onSurface: AppColors.lightTextPrimary,
        onBackground: AppColors.lightTextPrimary,
        outline: AppColors.lightOutline,
        surfaceVariant: AppColors.lightCard,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.primaryBlue.withOpacity(0.1),
        iconTheme: MaterialStateProperty.all(const IconThemeData(size: 24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: AppColors.lightTextSecondary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) => 
          states.contains(MaterialState.selected) ? AppColors.primaryBlue : AppColors.lightTextSecondary),
        trackColor: MaterialStateProperty.resolveWith((states) => 
          states.contains(MaterialState.selected) ? AppColors.primaryBlue.withOpacity(0.4) : AppColors.lightOutline),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.lightTextPrimary),
        displayMedium: TextStyle(color: AppColors.lightTextPrimary),
        headlineLarge: TextStyle(color: AppColors.lightTextPrimary),
        titleLarge: TextStyle(color: AppColors.lightTextPrimary),
        bodyLarge: TextStyle(color: AppColors.lightTextPrimary),
        bodyMedium: TextStyle(color: AppColors.lightTextSecondary),
      ),
    );
  }
}
