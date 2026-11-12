import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BrandColors {
  BrandColors._();
  static const primary = Color(0xFF1E40AF); // brand-600
  static const primaryLight = Color(0xFF1A56DB); // brand-500
  static const primaryDark = Color(0xFF1E3A8A); // brand-700
  static const gold = Color(0xFFC99B3B);
  static const bgLight = Color(0xFFF4F7FB);
  static const bgDark = Color(0xFF0B1220);
  static const ok = Color(0xFF059669);
  static const warn = Color(0xFFD97706);
  static const danger = Color(0xFFDC2626);
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

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: BrandColors.primary,
    brightness: brightness,
    primary: dark ? const Color(0xFF6EA0FF) : BrandColors.primary,
    secondary: BrandColors.gold,
    surface: dark ? const Color(0xFF111B2E) : Colors.white,
  );
  final base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: brightness);
  final textTheme = GoogleFonts.figtreeTextTheme(base.textTheme);
  final scaffold = dark ? BrandColors.bgDark : BrandColors.bgLight;
  final border = dark ? const Color(0xFF22314D) : const Color(0xFFE3EAF3);

  return base.copyWith(
    textTheme: textTheme,
    scaffoldBackgroundColor: scaffold,
    appBarTheme: AppBarTheme(
      backgroundColor: dark ? const Color(0xFF0E1830) : BrandColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: border),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: border)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: dark ? const Color(0xFF0E1830) : Colors.white,
      indicatorColor: BrandColors.primary.withValues(alpha: dark ? 0.35 : 0.12),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: dark ? Colors.white70 : const Color(0xFF475569)),
      ),
    ),
  );
}

/// Helpers so screens stay theme-aware without repeating brightness checks.
extension ThemeX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get muted => isDark ? const Color(0xFF9FB0CC) : const Color(0xFF64748B);
  Color get hairline => isDark ? const Color(0xFF22314D) : const Color(0xFFE3EAF3);
}
