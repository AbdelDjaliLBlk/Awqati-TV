// lib/core/theme/app_theme.dart
// Premium Islamic aesthetic theme for Noor application

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // Primary Islamic Gold
  static const Color gold = Color(0xFFD4A843);
  static const Color goldLight = Color(0xFFE8C96B);
  static const Color goldDark = Color(0xFFA07820);

  // Deep Night (primary background)
  static const Color deepNight = Color(0xFF0A0E1A);
  static const Color midnight = Color(0xFF0D1221);
  static const Color navyDeep = Color(0xFF111827);

  // Surface colors
  static const Color surface = Color(0xFF1A2035);
  static const Color surfaceLight = Color(0xFF232B42);
  static const Color surfaceLighter = Color(0xFF2D3650);

  // Accent - Emerald Islamic
  static const Color emerald = Color(0xFF2ECC71);
  static const Color emeraldDark = Color(0xFF27AE60);
  static const Color teal = Color(0xFF1ABC9C);

  // Text
  static const Color textPrimary = Color(0xFFF5F0E8);
  static const Color textSecondary = Color(0xFFB0A898);
  static const Color textMuted = Color(0xFF6B7280);

  // Prayer highlight
  static const Color prayerActive = Color(0xFFD4A843);
  static const Color prayerNext = Color(0xFF2ECC71);
  static const Color prayerPast = Color(0xFF4B5563);

  // Light theme
  static const Color lightBackground = Color(0xFFF8F4EC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFF0EBE0);
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF4A4A6A);

  // TV focus highlight
  static const Color tvFocus = Color(0xFFD4A843);
  static const Color tvFocusBorder = Color(0xFFE8C96B);

  // Gradient presets
  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldLight, gold, goldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient nightGradient = LinearGradient(
    colors: [deepNight, midnight, navyDeep],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const RadialGradient athanGradient = RadialGradient(
    colors: [Color(0xFF1A0A00), Color(0xFF0A0520), Color(0xFF000510)],
    center: Alignment.center,
    radius: 1.2,
  );
}

class AppTheme {
  AppTheme._();

  // Arabic-friendly text theme using Amiri + Latin combo
  static TextTheme _buildTextTheme(bool isDark) {
    final baseColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final secondaryColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return TextTheme(
      // Display - used for clock
      displayLarge: GoogleFonts.cinzelDecorative(
        fontSize: 72,
        fontWeight: FontWeight.w400,
        color: baseColor,
        letterSpacing: 2,
      ),
      displayMedium: GoogleFonts.cinzelDecorative(
        fontSize: 48,
        fontWeight: FontWeight.w400,
        color: baseColor,
        letterSpacing: 1.5,
      ),
      displaySmall: GoogleFonts.cinzelDecorative(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),

      // Headlines - section titles
      headlineLarge: GoogleFonts.cormorantGaramond(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0.5,
      ),
      headlineMedium: GoogleFonts.cormorantGaramond(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineSmall: GoogleFonts.cormorantGaramond(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),

      // Title - prayer names, labels
      titleLarge: GoogleFonts.josefinSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 1.5,
      ),
      titleMedium: GoogleFonts.josefinSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: baseColor,
        letterSpacing: 1.2,
      ),
      titleSmall: GoogleFonts.josefinSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
        letterSpacing: 1.0,
      ),

      // Body
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      bodySmall: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
      ),

      // Label
      labelLarge: GoogleFonts.josefinSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 1.2,
      ),
      labelMedium: GoogleFonts.josefinSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
        letterSpacing: 1.0,
      ),
      labelSmall: GoogleFonts.josefinSans(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        letterSpacing: 0.8,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.deepNight,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        secondary: AppColors.emerald,
        surface: AppColors.surface,
        background: AppColors.deepNight,
        onPrimary: AppColors.deepNight,
        onSecondary: AppColors.deepNight,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        tertiary: AppColors.teal,
        error: Color(0xFFE74C3C),
      ),
      textTheme: _buildTextTheme(true),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.gold),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color(0x20D4A843),
            width: 1,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0x20D4A843),
        thickness: 1,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.gold,
        size: 24,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.deepNight,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.josefinSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ),
      focusColor: AppColors.tvFocus.withOpacity(0.15),
    );
  }

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.goldDark,
        secondary: AppColors.emeraldDark,
        surface: AppColors.lightSurface,
        background: AppColors.lightBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.lightTextPrimary,
        onBackground: AppColors.lightTextPrimary,
      ),
      textTheme: _buildTextTheme(false),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.goldDark),
      ),
      cardTheme: CardTheme(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color(0x30A07820),
            width: 1,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0x25A07820),
        thickness: 1,
      ),
    );
  }
}

// Arabic text style helper
class ArabicTextStyles {
  ArabicTextStyles._();

  static TextStyle quranText({
    double fontSize = 28,
    Color color = AppColors.textPrimary,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return TextStyle(
      fontFamily: 'ScheherazadeNew',
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      height: 2.0,
      letterSpacing: 0,
    );
  }

  static TextStyle arabicUI({
    double fontSize = 18,
    Color color = AppColors.textPrimary,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return TextStyle(
      fontFamily: 'Amiri',
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      height: 1.8,
    );
  }
}
