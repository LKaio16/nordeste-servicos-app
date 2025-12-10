import 'package:flutter/material.dart';

/// Cores do app Me Leva Noronha baseadas no protótipo
class AppColors {
  // Cores primárias
  static const Color primary = Color(0xFF19277C);
  static const Color primaryHover = Color(0xFF141F63);
  
  // Backgrounds
  static const Color secondaryBg = Color(0xFFF5F3EF);
  static const Color tertiaryBg = Color(0xFFF9FAFB);
  static const Color white = Colors.white;
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  
  // Accent colors
  static const Color accent = Color(0xFF9D8B6C);
  static const Color green = Color(0xFF3A6B60);
  static const Color orange = Color(0xFFC67C3B);
  
  // WhatsApp green
  static const Color whatsappGreen = Color(0xFF25D366);
  static const Color whatsappGreenDark = Color(0xFF1FB855);
  
  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  
  // Emergency colors
  static const Color emergencyRed = Color(0xFFDC2626);
  static const Color emergencyBlue = Color(0xFF1D4ED8);
  
  // Tour category colors
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber900 = Color(0xFF78350F);
  static const Color amber800 = Color(0xFF92400E);
  
  // Gradient helpers
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [primary, primaryHover],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get whatsappGradient => const LinearGradient(
    colors: [whatsappGreen, Color(0xFF128C7E)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}







