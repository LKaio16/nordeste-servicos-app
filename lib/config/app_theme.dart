import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Tema do app Me Leva Noronha
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.gray50,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.white,
        background: AppColors.gray50,
        brightness: Brightness.light,
      ),
      
      textTheme: GoogleFonts.ralewayTextTheme().copyWith(
        displayLarge: GoogleFonts.raleway(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.gray800,
        ),
        displayMedium: GoogleFonts.raleway(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.gray800,
        ),
        displaySmall: GoogleFonts.raleway(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.gray800,
        ),
        headlineLarge: GoogleFonts.raleway(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.gray800,
        ),
        headlineMedium: GoogleFonts.raleway(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.gray800,
        ),
        headlineSmall: GoogleFonts.raleway(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.gray800,
        ),
        titleLarge: GoogleFonts.raleway(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.gray800,
        ),
        titleMedium: GoogleFonts.raleway(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.gray800,
        ),
        titleSmall: GoogleFonts.raleway(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.gray800,
        ),
        bodyLarge: GoogleFonts.raleway(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.gray700,
        ),
        bodyMedium: GoogleFonts.raleway(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.gray600,
        ),
        bodySmall: GoogleFonts.raleway(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.gray500,
        ),
        labelLarge: GoogleFonts.raleway(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.gray700,
        ),
        labelMedium: GoogleFonts.raleway(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.gray600,
        ),
        labelSmall: GoogleFonts.raleway(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.gray500,
        ),
      ),
      
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.raleway(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.gray500,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.raleway(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.raleway(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gray200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gray200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.white,
        selectedColor: AppColors.primary,
        labelStyle: GoogleFonts.raleway(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      dividerTheme: const DividerThemeData(
        color: AppColors.gray200,
        thickness: 1,
      ),
    );
  }
}

