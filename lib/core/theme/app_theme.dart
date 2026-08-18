import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF6366F1); // Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color accentColor = Color(0xFF10B981); // Emerald

  // Neutral Colors (Light)
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color surfaceColor = Colors.white;
  static const Color textBodyColor = Color(0xFF1E293B);
  static const Color textHintColor = Color(0xFF94A3B8);
  static const Color textSecondaryColor = Color(0xFF64748B);

  // Neutral Colors (Dark)
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color textBodyDark = Color(0xFFF1F5F9);
  static const Color textHintDark = Color(0xFF64748B);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Status Colors
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, Color(0xFF818CF8)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
  );

  // Common Border Radius
  static final BorderRadius radiusSmall = BorderRadius.circular(8);
  static final BorderRadius radiusMedium = BorderRadius.circular(16);
  static final BorderRadius radiusLarge = BorderRadius.circular(24);
  static final BorderRadius radiusFull = BorderRadius.circular(100);

  static ThemeData lightTheme = _buildTheme(Brightness.light);
  static ThemeData darkTheme = _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bgColor = isDark ? backgroundDark : backgroundColor;
    final surfColor = isDark ? surfaceDark : surfaceColor;
    final textColor = isDark ? textBodyDark : textBodyColor;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bgColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
        primary: primaryColor,
        secondary: accentColor,
        surface: surfColor,
        error: errorColor,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        displaySmall: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        bodyLarge: GoogleFonts.outfit(fontSize: 16, color: textColor),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          color: isDark ? textSecondaryDark : textSecondaryColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: radiusMedium),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          minimumSize: const Size(double.infinity, 56),
          side: BorderSide(
            color: isDark ? textHintDark : textHintColor,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(borderRadius: radiusMedium),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfColor,
        contentPadding: const EdgeInsets.all(20),
        labelStyle: TextStyle(color: isDark ? textHintDark : textHintColor),
        hintStyle: TextStyle(color: isDark ? textHintDark : textHintColor),
        border: OutlineInputBorder(
          borderRadius: radiusMedium,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusMedium,
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusMedium,
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radiusMedium,
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: radiusLarge,
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
    );
  }
}
