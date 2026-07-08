import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF0E2B67);
  static const secondary = Color(0xFFE5A000);
  static const accent = Color(0xFF0D64CB);

  static const bodyText = Color(0xFF1A1A2E);
  static const bodyTextSecondary = Color(0xFF6B7280);
  static const surface = Color(0xFFF8F9FC);
  static const white = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          tertiary: AppColors.accent,
          surface: AppColors.surface,
          onPrimary: AppColors.white,
          onSecondary: AppColors.white,
          onSurface: AppColors.bodyText,
        ),
        scaffoldBackgroundColor: AppColors.surface,
        textTheme: TextTheme(
          displayLarge: GoogleFonts.sora(color: AppColors.bodyText, fontWeight: FontWeight.bold),
          displayMedium: GoogleFonts.sora(color: AppColors.bodyText, fontWeight: FontWeight.bold),
          displaySmall: GoogleFonts.sora(color: AppColors.bodyText, fontWeight: FontWeight.bold),
          headlineLarge: GoogleFonts.sora(color: AppColors.bodyText, fontWeight: FontWeight.w700),
          headlineMedium: GoogleFonts.sora(color: AppColors.bodyText, fontWeight: FontWeight.w600),
          headlineSmall: GoogleFonts.sora(color: AppColors.bodyText, fontWeight: FontWeight.w600),
          titleLarge: GoogleFonts.sora(color: AppColors.bodyText, fontWeight: FontWeight.w600),
          titleMedium: GoogleFonts.sora(color: AppColors.bodyText, fontWeight: FontWeight.w500),
          titleSmall: GoogleFonts.sora(color: AppColors.bodyText, fontWeight: FontWeight.w500),
          bodyLarge: GoogleFonts.inter(color: AppColors.bodyText, fontWeight: FontWeight.normal),
          bodyMedium: GoogleFonts.inter(color: AppColors.bodyText, fontWeight: FontWeight.normal),
          bodySmall: GoogleFonts.inter(color: AppColors.bodyTextSecondary, fontWeight: FontWeight.normal),
          labelLarge: GoogleFonts.inter(color: AppColors.bodyText, fontWeight: FontWeight.w500),
          labelMedium: GoogleFonts.inter(color: AppColors.bodyTextSecondary, fontWeight: FontWeight.w500),
          labelSmall: GoogleFonts.inter(color: AppColors.bodyTextSecondary, fontWeight: FontWeight.w400),
        ),
      );
}
