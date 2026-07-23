import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: AppColors.primaryBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryGlow,
        secondary: AppColors.accent,
        surface: AppColors.secondaryBackground,
        onSurface: AppColors.textWhite,
        onPrimary: AppColors.primaryBackground,
      ),
      cardTheme: CardThemeData(
        color: AppColors.secondaryBackground,
        elevation: 6,
        shadowColor: AppColors.primaryGlow.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.glassBorder, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.orbitron(
          color: AppColors.primaryGlow,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        iconTheme: const IconThemeData(color: AppColors.primaryGlow),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.orbitron(
          color: AppColors.textWhite,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
        displayMedium: GoogleFonts.orbitron(
          color: AppColors.primaryGlow,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
        headlineMedium: GoogleFonts.orbitron(
          color: AppColors.textWhite,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.rajdhani(
          color: AppColors.textLightBlue,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: GoogleFonts.rajdhani(
          color: AppColors.textWhite,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: GoogleFonts.rajdhani(
          color: AppColors.textLightBlue,
          fontSize: 14,
        ),
        labelLarge: GoogleFonts.orbitron(
          color: AppColors.primaryBackground,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.secondaryBackground.withValues(alpha: 0.8),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        labelStyle: const TextStyle(color: AppColors.textLightBlue),
        prefixIconColor: AppColors.primaryGlow,
        suffixIconColor: AppColors.primaryGlow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGlow, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.systemWarningRed),
        ),
      ),
    );
  }
}
