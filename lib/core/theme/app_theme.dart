import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

/// Material 3 theme — light + dark variants.
/// Accepts a [Locale] so Arabic automatically uses the Cairo font.
class AppTheme {
  AppTheme._();

  static const Color _seed = AppColors.primary;

  // ── Text Theme ─────────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Brightness brightness, Locale locale) {
    final base = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;

    final isArabic = locale.languageCode == 'ar';

    if (isArabic) {
      // Use Cairo for Arabic — it supports Arabic script beautifully
      return GoogleFonts.cairoTextTheme(base);
    }

    // Default: Outfit for headings, Inter for body (Latin)
    return GoogleFonts.outfitTextTheme(base).copyWith(
      bodySmall:   GoogleFonts.inter(fontSize: 12),
      bodyMedium:  GoogleFonts.inter(fontSize: 14),
      bodyLarge:   GoogleFonts.inter(fontSize: 16),
      labelSmall:  GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
      labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
      labelLarge:  GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  // ── Shared component themes ────────────────────────────────────────────────
  static CardThemeData _cardTheme(ColorScheme cs) => CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: cs.brightness == Brightness.light
            ? Colors.black.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.06),
      ),
    ),
    color: cs.brightness == Brightness.light
        ? AppColors.cardLight
        : AppColors.cardDark,
  );

  static InputDecorationTheme _inputTheme(ColorScheme cs) => InputDecorationTheme(
    filled: true,
    fillColor: cs.surfaceContainerHighest.withOpacity(0.5),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: cs.outlineVariant.withOpacity(0.4)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: cs.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: cs.error),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme cs) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      );

  static ChipThemeData _chipTheme(ColorScheme cs) => ChipThemeData(
    backgroundColor: cs.surfaceContainerHighest,
    selectedColor: cs.primaryContainer,
    labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    side: BorderSide.none,
  );

  static NavigationBarThemeData _navBarTheme(ColorScheme cs) =>
      NavigationBarThemeData(
        height: 72,
        indicatorColor: cs.primaryContainer,
        backgroundColor: cs.surface,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.primary,
            );
          }
          return GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500);
        }),
      );

  static AppBarTheme _appBarTheme(ColorScheme cs) => AppBarTheme(
    backgroundColor: cs.surface,
    foregroundColor: cs.onSurface,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: GoogleFonts.outfit(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: cs.onSurface,
    ),
  );

  // ── Light ──────────────────────────────────────────────────────────────────
  static ThemeData lightTheme(Locale locale) {
    final cs = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: _buildTextTheme(Brightness.light, locale),
      cardTheme: _cardTheme(cs),
      inputDecorationTheme: _inputTheme(cs),
      elevatedButtonTheme: _elevatedButtonTheme(cs),
      chipTheme: _chipTheme(cs),
      navigationBarTheme: _navBarTheme(cs),
      appBarTheme: _appBarTheme(cs),
      scaffoldBackgroundColor: AppColors.surface,
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant.withValues(alpha: 0.4),
        thickness: 1,
      ),
    );
  }

  // ── Dark (AMOLED) ───────────────────────────────────────────────────────────
  static ThemeData darkTheme(Locale locale) {
    // Build a seed-based scheme but override critical AMOLED colors
    final seedCs = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    );
    // Override surface/background to true black
    final cs = seedCs.copyWith(
      surface: AppColors.surfaceDark,           // 0xFF000000
      onSurface: Colors.white,
      surfaceContainerHighest: const Color(0xFF1A1A1A),
      surfaceContainer: const Color(0xFF0D0D0D),
      surfaceContainerLow: const Color(0xFF111111),
      surfaceContainerLowest: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: _buildTextTheme(Brightness.dark, locale),
      cardTheme: _cardTheme(cs),
      inputDecorationTheme: _inputTheme(cs),
      elevatedButtonTheme: _elevatedButtonTheme(cs),
      chipTheme: _chipTheme(cs),
      navigationBarTheme: _navBarTheme(cs).copyWith(
        backgroundColor: AppColors.surfaceDark,
      ),
      appBarTheme: _appBarTheme(cs).copyWith(
        backgroundColor: AppColors.surfaceDark,
      ),
      scaffoldBackgroundColor: AppColors.surfaceDark,
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant.withValues(alpha: 0.25),
        thickness: 1,
      ),
      bottomAppBarTheme: const BottomAppBarThemeData(
        color: Color(0xFF0A0A0A),
        elevation: 0,
      ),
    );
  }

  // ── Backwards-compat statics (used elsewhere; default to 'en') ─────────────
  static ThemeData get light  => lightTheme(const Locale('en'));
  static ThemeData get dark   => darkTheme(const Locale('en'));
}
