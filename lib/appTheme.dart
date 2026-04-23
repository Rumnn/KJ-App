import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Colors based on KanjiFlow design
  static const Color primary = Color(0xFF4352A5);
  static const Color primaryContainer = Color(0xFF5C6BC0);
  static const Color onPrimaryContainer = Color(0xFFF8F6FF);
  
  static const Color secondary = Color(0xFF006A62); // Teal for progress
  static const Color background = Color(0xFFF7F9FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFECEEF0);
  
  static const Color tertiary = Color(0xFF804D00); // Streak/Fire
  static const Color tertiaryFixedDim = Color(0xFFFFB866);
  
  static const Color error = Color(0xFFBA1A1A);
  static const Color onBackground = Color(0xFF191C1E);
  static const Color textSecondary = Color(0xFF454651);
  static const Color textMuted = Color(0xFF767683);
  static const Color outlineVariant = Color(0xFFC6C5D3);

  // Compatibility Aliases
  static const Color accent = primary;
  static const Color accentLight = primaryContainer;
  static const Color accentGlow = Color(0x334352A5);
  static const Color gold = tertiary;
  static const Color success = secondary;
  static const Color textPrimary = onBackground;
  static const Color border = outlineVariant;
  static const Color card = surface;
  static const Color cardHover = surfaceContainer;
  static const LinearGradient cardGradient = accentGradient;

  static const LinearGradient accentGradient = LinearGradient(
    colors: [primary, primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const List<Color> jlptColors = [
    Color(0xFF4CAF7D),
    Color(0xFF5B9BD5),
    Color(0xFFE8B84B),
    Color(0xFFE06B4A),
    Color(0xFF9B5DE5),
  ];

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: surface,
      error: error,
      onPrimary: Colors.white,
      onSurface: onBackground,
    ),
    // Using Lexend font as per design
    textTheme: GoogleFonts.lexendTextTheme(const TextTheme(
      displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: onBackground, letterSpacing: -1.5),
      displayMedium: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: onBackground, letterSpacing: -1),
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: onBackground),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: onBackground),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: onBackground),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: onBackground),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: onBackground),
      bodyLarge: TextStyle(fontSize: 18, color: onBackground),
      bodyMedium: TextStyle(fontSize: 16, color: textSecondary),
      bodySmall: TextStyle(fontSize: 14, color: textMuted),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: onBackground, letterSpacing: 0.5),
      labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textMuted, letterSpacing: 0.05),
    )),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: primary),
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: primary),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: outlineVariant.withValues(alpha: 0.3), width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: outlineVariant)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: outlineVariant)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primary, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: error)),
      labelStyle: const TextStyle(color: textSecondary),
      prefixIconColor: textMuted,
      suffixIconColor: textMuted,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: primary,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        elevation: 4,
        shadowColor: primary.withValues(alpha: 0.15),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primary,
      unselectedItemColor: Color(0xFF94A3B8),
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}