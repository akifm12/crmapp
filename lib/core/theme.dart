import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BrandColors {
  BrandColors._();
  static const primary = Color(0xFF1E40AF); // brand-600
  static const primaryLight = Color(0xFF1A56DB); // brand-500
  static const primaryDark = Color(0xFF1E3A8A); // brand-700
  static const gold = Color(0xFFC99B3B);
}

/// Mirrors the badge colour semantics used by the Laravel models'
/// categoryBadgeColor()/badge() helpers, for visual continuity with the
/// website. Falls back to grey for unknown keys.
class BadgeColors {
  BadgeColors._();

  static const _map = <String, Color>{
    'red': Color(0xFFDC2626),
    'amber': Color(0xFFD97706),
    'orange': Color(0xFFEA580C),
    'blue': Color(0xFF2563EB),
    'purple': Color(0xFF9333EA),
    'emerald': Color(0xFF059669),
    'gray': Color(0xFF6B7280),
  };

  /// The API returns Tailwind-style class strings like
  /// "bg-amber-100 text-amber-700" — pull the colour family out of that.
  static Color fromTailwindClasses(String classes) {
    for (final key in _map.keys) {
      if (classes.contains(key)) return _map[key]!;
    }
    return _map['gray']!;
  }
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: BrandColors.primary,
      primary: BrandColors.primary,
      secondary: BrandColors.gold,
      brightness: Brightness.light,
    ),
  );

  final textTheme = GoogleFonts.figtreeTextTheme(base.textTheme);

  return base.copyWith(
    textTheme: textTheme,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    appBarTheme: AppBarTheme(
      backgroundColor: BrandColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: EdgeInsets.zero,
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: BrandColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: BrandColors.primary,
      unselectedItemColor: Color(0xFF9CA3AF),
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
    ),
  );
}
