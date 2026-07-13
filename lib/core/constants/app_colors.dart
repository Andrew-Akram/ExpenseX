import 'package:flutter/material.dart';

/// Central colour palette — used across the entire app.
/// All raw colour values live here; never hard-code hex elsewhere.
class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color primary   = Color(0xFF7B6CF6); // Vibrant purple (matches mockup)
  static const Color secondary = Color(0xFF5F59F7); // Deep purple
  static const Color tertiary  = Color(0xFF3B37C4); // Darker purple
  static const Color accent    = Color(0xFFB4AEFF); // Soft lavender

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error   = Color(0xFFEF4444);
  static const Color info    = Color(0xFF3B82F6);

  // ── Neutral ────────────────────────────────────────────────────────────────
  static const Color surface     = Color(0xFFF6F8FA);
  static const Color surfaceDark = Color(0xFF000000);
  static const Color cardLight   = Color(0xFFFFFFFF);
  static const Color cardDark    = Color(0xFF111111);

  // ── Category palette ───────────────────────────────────────────────────────
  static const Color catFood           = Color(0xFFEF4444);
  static const Color catTransportation = Color(0xFF3B82F6);
  static const Color catShopping       = Color(0xFFEC4899);
  static const Color catBills          = Color(0xFF10B981);
  static const Color catEntertainment  = Color(0xFFF59E0B);
  static const Color catHealth         = Color(0xFF8B5CF6);
  static const Color catEducation      = Color(0xFF06B6D4);
  static const Color catTravel         = Color(0xFF14B8A6);
  static const Color catOther          = Color(0xFF6B7280);

  // ── Gradient presets ───────────────────────────────────────────────────────
  // Light purple gradient for dashboard header (matches mockup)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF9D8FFF), Color(0xFF7B6CF6), Color(0xFF5F59F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Light mode dashboard header gradient
  static const LinearGradient dashboardLightGradient = LinearGradient(
    colors: [Color(0xFFB8AEFF), Color(0xFF9D8FFF), Color(0xFF7B6CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );


  static const LinearGradient dashboardDarkGradient = LinearGradient(
    colors: [Color(0xFF5F59F7), Color(0xFF3B37C4), Color(0xFF1A1060)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF000000), Color(0xFF111111)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
